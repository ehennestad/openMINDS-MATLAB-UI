classdef ModelBuilder < handle
%     
%   TODO:
%       [x] Save figure size to app settings
%       [x] Save metadata set
%       [ ] Fill out all linked types which are not controlled terms with
%           categoricals where each value is a id/label for one of the linked
%           types...
%       [ ] Add label for required properties in table columns and editor...
%       [ ] Check out BCCN
%       [ ] Move +category to +openminds
%       [ ] Fix broken controlled terms
%       [ ] Add way to have array of linked types on property
%       [ ] Add incoming links for schemas
%       [ ] Get label/id as method on Schema class
%       [ ] In table view, show connected nodes, in graph view, show all
%           available, or show predefined templates...
%       [ ] Dynamic listbox on left side panel
%
%       [ ] Treat embedded types and linked types differently. Embedded
%           types are not added to the set, but only added to schema 
%           instances. Should embedded types be value classes.
%
%       [ ] Linked types are just links...


% ABBREVIATIONS:
%       
%       OM : openMinds
%

    properties
        MetadataInstance
        MetadataCollection openminds.MetadataCollection
        MetadataSet
    end

    properties (Constant)
        Pages = {'Table Viewer', 'Graph Viewer', 'Timeline Viewer'} %, 'Figures'}
    end

    properties (SetAccess = private)
        CurrentSchemaTableName char
    end

    properties (Access = public) % UI Components
        Figure
    end

    properties (Access = private) % UI Components
        UIPanel
        UIContainer
        UIMetaTableViewer
        UISideBar
        UIGraphViewer
    end

    properties (Access = private)
        SchemaMenu
    end

    properties (Access = private, Dependent)
        SaveFolder
    end

    properties (Constant)
        METADATA_COLLECTION_FILENAME = 'metadata_collection.mat'
    end
    
% Create figure

    methods

        function obj = ModelBuilder(metadataCollection)

            if nargin < 1            
                obj.loadMetadataCollection()
            else
                obj.MetadataCollection = metadataCollection;
                obj.MetadataCollection.createListenersForAllInstances()
            end

            obj.createFigure()
            obj.createPanels()

            obj.updateLayoutPositions()

            obj.createTabGroup()

            obj.createSchemaSelectorSidebar()
            obj.plotOpenMindsLogo()


            % % Create graph of the core module of openMINDS
            [G,e] = om.internal.graph.generateGraph('core');
            
            hAxes = axes(obj.UIContainer.UITab(2));
            hAxes.Position = [0,0,0.999,1];

            G = obj.MetadataCollection.graph;
            addlistener(obj.MetadataCollection, 'CollectionChanged', @obj.onMetadataCollectionChanged);

            obj.addMetadataCollectionListeners()


            h = om.internal.graphics.InteractiveOpenMINDSPlot(G, hAxes, e);
            obj.UIGraphViewer = h;

            % NB NB NB: Some weird bug occurs if this is created before the
            % axes with the graph plot, where the axes current point seems
            % to be reversed in the y-dimension.
            columnSettings = obj.loadMetatableColumnSettings();
            nvPairs = {'ColumnSettings', columnSettings};
            h = nansen.MetaTableViewer( obj.UIContainer.UITab(1), [], nvPairs{:});
            h.HTable.KeyPressFcn = @obj.onKeyPressed;
            obj.UIMetaTableViewer = h;

            colSettings = h.ColumnSettings;
            [colSettings(:).IsEditable] = deal(true);
            h.ColumnSettings = colSettings;
            %obj.UIMetaTableViewer.HTable.Units

            h.CellEditCallback = @obj.onMetaTableDataChanged;


            [menuInstance, graphicsMenu] = om.TableContextMenu(obj.Figure);
            obj.UIMetaTableViewer.TableContextMenu = graphicsMenu;
            menuInstance.DeleteItemFcn = @obj.onDeleteMetadataInstanceClicked;

            %modelRoot = fullfile(om.Constants.SchemaFolder, 'matlab', '+openminds');
            %modelRoot = fullfile(om.Constants.SchemaFolder, 'matlab-alias', '+openminds');

            modelRoot = fullfile(openminds.internal.rootpath, 'schemas', 'latest', '+openminds');
            ignoreList = {'+category', '+linkset', '+controlledterms'};
            omModels = om.dir.listSubDir(modelRoot, '', ignoreList)';

            %omModels = {'openminds.core', 'openminds.sands'};
            obj.SchemaMenu = om.SchemaMenu(obj, omModels, true);
            obj.SchemaMenu.MenuSelectedFcn = @obj.onSchemaMenuItemSelected;

            % Add these callbacks after every component is made
            obj.Figure.SizeChangedFcn = @(s, e) obj.onFigureSizeChanged;
            obj.Figure.CloseRequestFcn = @obj.onExit;

            obj.changeSelection('Subject')
                       
            obj.configureFigureInteractionCallbacks()

            if ~nargout
                clear obj
            end
        end

        function delete(obj)
            % Save column view settings to project
            obj.saveMetatableColumnSettings()
            
%             if isempty(app.MetaTable)
%                 return
%             end
            
            isdeletable = @(x) ~isempty(x) && isvalid(x);
            
            if isdeletable(obj.UIMetaTableViewer)
                delete(obj.UIMetaTableViewer)
            end

            delete(obj.MetadataCollection)
            delete(obj.UIGraphViewer)
            delete(obj.UIMetaTableViewer)

            delete(obj.Figure)
        end

        function onExit(obj, src, evt)
            obj.saveMetadataCollection()
            obj.saveGraphCoordinates() % Todo

            windowPosition = obj.Figure.Position;
            setpref('openMINDS', 'WindowSize', windowPosition)

            delete(obj)
        end

    end

    methods %Set / get 
        function saveFolder = get.SaveFolder(~)
            % Todo: Get from preferences
            saveFolder = fullfile(userpath, 'openMINDS', 'userdata');
            if ~isfolder(saveFolder); mkdir(saveFolder); end
        end
    end

    methods

        function changeSelection(obj, schemaName)
            if any(strcmp(obj.UISideBar.Items, schemaName))
                obj.UISideBar.SelectedItems = schemaName;
            end
        end
        
        function updateLayoutPositions(obj)
            
            figPosPix = getpixelposition(obj.Figure);
            W = figPosPix(3);
            H = figPosPix(4);

            MARGIN = 10;
            PADDING = 10;

            toolH = 30;
            logoW = 150;
            logoH = round( logoW / 1.8784 );

            obj.UIPanel.Toolbar.Position = [MARGIN,H-MARGIN-toolH,W-MARGIN*2,toolH];
            
            h = H-MARGIN*2-toolH-PADDING;
            w = 150;
            obj.UIPanel.SidebarL.Position = [MARGIN, MARGIN+PADDING+logoH,logoW,h-logoH-PADDING];
            obj.UIPanel.Table.Position = [w+MARGIN+PADDING, MARGIN, W-MARGIN*2-w-PADDING, h];

            obj.UIPanel.Logo.Position = [MARGIN, MARGIN, logoW, logoH];
        end

        function columnSettings = loadMetatableColumnSettings(obj)
            rootDir = fileparts(mfilename('fullpath'));
            filename = fullfile(rootDir, 'table_column_settings.mat');
            try
                S = load(filename, 'columnSettings');
                columnSettings = S.columnSettings;
            catch
                columnSettings = struct.empty;
            end
        end

        function saveMetatableColumnSettings(obj)
            if isempty(obj.UIMetaTableViewer); return; end
            columnSettings = obj.UIMetaTableViewer.ColumnSettings;

            rootDir = fileparts(mfilename('fullpath'));
            filename = fullfile(rootDir, 'table_column_settings.mat');

            save(filename, 'columnSettings');
        end

    end

    methods (Access = private) % Internal utility methods
        function exportToWorkspace(obj)
            schemaName = obj.CurrentSchemaTableName;
            idx = obj.UIMetaTableViewer.getSelectedEntries();
            schemaInstance = obj.MetadataCollection.getSchemaInstanceByIndex(schemaName, idx);
            
            varName = matlab.lang.makeValidName( schemaInstance.DisplayString );
            assignin('base', varName, schemaInstance)
        end
    end

    methods (Access = private) % App initialization and update methods
        
        function windowPosition = getWindowPosition(~)
            if ispref('openMINDS', 'WindowSize')
                windowPosition = getpref('openMINDS', 'WindowSize');
            else
                windowPosition = [100, 100, 1000, 600];
            end
        end

        function createFigure(obj)
            windowPosition = obj.getWindowPosition();
            obj.Figure = figure('Position', windowPosition);
            obj.Figure.Name = 'openMINDS';
            obj.Figure.NumberTitle = 'off';
            obj.Figure.MenuBar = 'none';
            obj.Figure.ToolBar = 'none';
        end

        function createPanels(obj)
            obj.UIPanel.Toolbar = uipanel(obj.Figure);
            obj.UIPanel.SidebarL = uipanel(obj.Figure);
            obj.UIPanel.Table = uipanel(obj.Figure);
            obj.UIPanel.Logo = uipanel(obj.Figure);
            
            panels = struct2cell(obj.UIPanel);
            set([panels{:}], 'Units', 'pixels', 'BackgroundColor', 'w', 'BorderType','etchedin')
        end

        function createTabGroup(obj)
        %createTabGroup Create the tabgroup container and add tabs

            obj.UIContainer.TabGroup = uitabgroup(obj.UIPanel.Table);
            obj.UIContainer.TabGroup.Units = 'normalized';

            obj.UIContainer.UITab = gobjects(0);

            for i = 1:numel(obj.Pages)
                pageName = obj.Pages{i};
                
                hTab = uitab(obj.UIContainer.TabGroup);
                hTab.Title = pageName;

                obj.UIContainer.UITab(i) = hTab;
            end
        end
        
        function createSchemaSelectorSidebar(obj)
        %createSchemaSelectorSidebar Create a selector widget in side panel    
            
            initSchemas = {'Subject', 'TissueSample', 'SubjectState', 'TissueSampleState'};
            
            sideBar = om.gui.control.ListBox(obj.UIPanel.SidebarL, initSchemas);
            sideBar.SelectionChangedFcn = @obj.onSelectionChanged;
            obj.UISideBar = sideBar;
        end

        function plotOpenMindsLogo(obj)
        %plotLogo Plot openMINDS logo in the logo panel   
            
            % Load the logo from file
            logoFilename = 'light_openMINDS-logo.png';
            logoFilename = om.ModelBuilder.getLogoFilepath();

            if ~exist(logoFilename, 'file')
                fprintf('Downloading openMINDS logo...'); fprintf(newline)
                obj.downloadOpenMindsLogo()
                fprintf('Download finished'); fprintf(newline)
            end

            [C, ~, A] = imread(logoFilename);

            % Create axes for plotting logo
            ax = axes(obj.UIPanel.Logo, 'Position', [0,0,1,1]);

            % Plot logo as image
            hImage = image(ax, 'CData', C);
            hImage.AlphaData = A;

            % Customize axes
            ax.Color = 'white';
            ax.YDir = 'reverse';
            ax.Visible = 'off';
        end

        function configureFigureInteractionCallbacks(obj)
            
            %obj.Figure.WindowButtonDownFcn = @obj.onMousePressed;
            %obj.Figure.WindowButtonMotionFcn = @obj.onMouseMotion;
            obj.Figure.WindowKeyPressFcn = @obj.onKeyPressed;
            %obj.Figure.WindowKeyReleaseFcn = @obj.onKeyReleased;
            
            %[~, hJ] = evalc('findjobj(obj.Figure)');
            %hJ(2).KeyPressedCallback = @obj.onKeyPressed;
            %hJ(2).KeyReleasedCallback = @obj.onKeyReleased;
            
        end

    end

    methods (Access = private) % Metadata Collection configuration methods

        function addMetadataCollectionListeners(obj)

            addlistener(obj.MetadataCollection, 'CollectionChanged', @obj.onMetadataCollectionChanged);
            addlistener(obj.MetadataCollection, 'InstanceModified', @obj.onMetadataInstanceModified);

        end

        function filepath = getMetadataCollectionFilepath(obj)
            filepath = fullfile(obj.SaveFolder, obj.METADATA_COLLECTION_FILENAME);
        end
        
        function saveMetadataCollection(obj)
            metadataFilepath = obj.getMetadataCollectionFilepath();
            
            % Todo: Serialize
            %S = struct;

            MetadataCollection = obj.MetadataCollection; %#ok<PROP> 
            save(metadataFilepath, 'MetadataCollection')
            % Todo: Are listeners saved???
        end

        function loadMetadataCollection(obj)
            metadataFilepath = obj.getMetadataCollectionFilepath();
            if isfile(metadataFilepath)
                S = load(metadataFilepath, 'MetadataCollection');
                obj.MetadataCollection = S.MetadataCollection;
                obj.MetadataCollection.createListenersForAllInstances()
            else
                obj.MetadataCollection = openminds.MetadataCollection();
            end


% % %             % Reattach listeners
% % %             addlistener(obj.MetadataCollection, 'CollectionChanged', ...
% % %                 @obj.onMetadataCollectionChanged)

        end

        function saveGraphCoordinates(obj)
            % Todo.
        end

    end

    methods (Access = private) % Internal callback methods
        
        function onKeyPressed(obj, src, evt)

            switch evt.Key
                case 'x'
                    obj.exportToWorkspace()
            end

        end

        function onMetaTableDataChanged(obj, src, evt)
            type = obj.CurrentSchemaTableName;
            instanceIdx = evt.Indices(1);
            propName = src.ColumnName{ evt.Indices(2) };
            propValue = evt.NewValue;
            obj.MetadataCollection.modifyInstance(type, instanceIdx, propName, propValue);
        end

        function onSelectionChanged(obj, src, evt)
            
            schemaName = evt.NewSelection;
            obj.CurrentSchemaTableName = schemaName;

            % check if schema has a table
            if numel(schemaName) == 1
                metaTable = obj.MetadataCollection.getTable(schemaName{1});
            else
                metaTable = obj.MetadataCollection.joinTables(schemaName);
            end

            obj.updateUITable(metaTable)
        end

        function onFigureSizeChanged(app)
            app.updateLayoutPositions()
        end

        function onSchemaMenuItemSelected(obj, functionName, selectionMode)
        % onSchemaMenuItemSelected - Instance menu selection callback

            % Simplify function name. In order to make gui menus more
            % userfriendly, the alias version of the schemas are used.
            functionNameSplit = strsplit(functionName, '.');
            functionName = strjoin(functionNameSplit([1,2,4]), '.');
            
            switch selectionMode
                case 'Single'
                    n = 1;
                case 'Multiple'
                    n = inputdlg('Enter number of items to create:');
                    if n{1}==0; return; end
                    n = str2double(n{1});
                case 'Help'
                    help(functionName)
                    return
                case 'Open'
                    open(functionName)
                    return
            end

            om.uiCreateNewInstance(functionName, obj.MetadataCollection, "NumInstances", n)

            % Todo: update tables...!

            className = functionNameSplit{end};
            obj.changeSelection(className)
        end
        
        function onMetadataCollectionChanged(obj, src, evt)
            
            G = obj.MetadataCollection.graph;
            obj.UIGraphViewer.updateGraph(G);
            
            T = obj.MetadataCollection.getTable(obj.CurrentSchemaTableName);
            obj.updateUITable(T)

        end

        function onMetadataInstanceModified(obj, src, evt)

            G = obj.MetadataCollection.graph;
            obj.UIGraphViewer.updateGraph(G);

            T = obj.MetadataCollection.getTable(obj.CurrentSchemaTableName);
            obj.updateUITable(T)
        end

        function onDeleteMetadataInstanceClicked(obj, src, evt)
            selectedIdx = obj.UIMetaTableViewer.getSelectedEntries();

            type = obj.CurrentSchemaTableName;

            obj.MetadataCollection.removeInstance(type, selectedIdx)

            T = obj.MetadataCollection.getTable(obj.CurrentSchemaTableName);
            obj.updateUITable(T)
            %app.MetaTable.removeEntries(selectedEntries)
            %app.UiMetaTableViewer.refreshTable(app.MetaTable)

        end
    end

    methods (Access = private) % Internal updating

        function updateUITable(obj, metaTable)

            if ~isempty(metaTable)
                %obj.UIMetaTableViewer.resetTable()
                obj.UIMetaTableViewer.refreshTable(metaTable, true)
            else
                obj.UIMetaTableViewer.resetTable()
                obj.UIMetaTableViewer.refreshTable(table.empty, true)
            end
        end

    end

    methods (Static)
        function deleteMetadataCollection()
            saveFolder = fullfile(userpath, 'openMINDS', 'userdata');
            metadataFilepath = fullfile(saveFolder, om.ModelBuilder.METADATA_COLLECTION_FILENAME);
            
            if isfile(metadataFilepath)
                delete(metadataFilepath)
            end
        end
    
        function tf = isSchemaInstanceUnavailable(value)
            tf = ~isempty(regexp(value, 'No \w* available', 'once'));
        end

        function [CData, AlphaData] = loadOpenMindsLogo()
            
            % Load the logo from file
            logoFilename = om.ModelBuilder.getLogoFilepath();
            
            if ~exist(logoFilename, 'file')
                fprintf('Downloading openMINDS logo...'); fprintf(newline)
                obj.downloadOpenMindsLogo()
                fprintf('Download finished'); fprintf(newline)
            end

            [CData, ~, AlphaData] = imread(logoFilename);
        end

        function downloadOpenMindsLogo()
            logoUrl = om.Constants.LogoLightURL;
            websave(om.ModelBuilder.getLogoFilepath(), logoUrl);
        end

        function logoFilepath = getLogoFilepath()
            logoUrl = om.Constants.LogoLightURL;
            logoURI = matlab.net.URI(logoUrl);
            
            % Download logo
            thisFullpathSplit = pathsplit( mfilename("fullpath") );
            fileName = logoURI.Path(end);

            logoFilepath = fullfile('/',thisFullpathSplit{1:end-2}, fileName);
        end
    end
end
