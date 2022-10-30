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
%       [ ] Dynamic listbok on left side

    properties
        MetadataInstance
        MetadataSet
    end

    properties
        Pages = {'Table Viewer', 'Graph Viewer', 'Timeline Viewer'}%, 'Figures'}
    end

    properties % UI Properties
        Figure
        UIPanel
        UIContainer
        UIMetaTableViewer
        UISideBar
        UITabGroup
    end

    properties (Access = private)
        SchemaMenu
    end

    properties (Access = private, Dependent)
        SaveFolder
    end
    
% Create figure

    methods

        function obj = ModelBuilder()
            
            obj.loadMetadataSet()
            
            if ispref('openMINDS', 'WindowSize')
                windowPosition = getpref('openMINDS', 'WindowSize');
            else
                windowPosition = [100, 100, 1000, 600];
            end

            hFigure = figure('Position', windowPosition, 'MenuBar','none', 'ToolBar','none');
            obj.Figure = hFigure;
            obj.Figure.Name = 'openMINDS';
            obj.Figure.NumberTitle = 'off';
            
            obj.UIPanel.Toolbar = uipanel(hFigure);
            obj.UIPanel.SidebarL = uipanel(hFigure);
            obj.UIPanel.Table = uipanel(hFigure);
            obj.UIPanel.Logo = uipanel(hFigure);
                        
            panels = [obj.UIPanel.Toolbar, obj.UIPanel.SidebarL, obj.UIPanel.Table, obj.UIPanel.Logo];
            set(panels, 'Units', 'pixels', 'BackgroundColor', 'w', 'BorderType','etchedin')

            obj.updateLayoutPositions()

            obj.UIContainer.TabGroup = uitabgroup(obj.UIPanel.Table);
            obj.UIContainer.TabGroup.Units = 'normalized';

            obj.createTabGroup()

            % Plot logo:
            ax = axes(obj.UIPanel.Logo, 'Position', [0,0,1,1]);
            ax.Color = 'white';
            [C, ~, A] = imread('light_openMINDS-logo.png');
            hImage = image(ax, 'CData', C);
            hImage.AlphaData = A;
            ax.YDir = 'reverse';
            ax.Visible = 'off';

           % hImage.Parent = ax;

            sideBar = om.gui.control.ListBox(obj.UIPanel.SidebarL, {'Subject', 'TissueSample', 'SubjectState', 'TissueSampleState'});
            sideBar.SelectionChangedFcn = @obj.onSelectionChanged;
            obj.UISideBar = sideBar;
            %metaTable = [];
            %pathStr = nansen.metadata.MetaTableCatalog.getDefaultMetaTablePath();
            %metaTable = nansen.metadata.MetaTable.open(pathStr);
            
            columnSettings = obj.loadMetatableColumnSettings();
            nvPairs = {'ColumnSettings', columnSettings};

            h = nansen.MetaTableViewer( obj.UIContainer.UITab(1), [], nvPairs{:});
            obj.UIMetaTableViewer = h;
            %obj.UIMetaTableViewer.HTable.Units

            % create graph plot
            [G,e] = om.generateGraph('core');
            hAxes = axes(obj.UIContainer.UITab(2));
            hAxes.Position = [0,0,0.999,1];
            InteractiveOpenMINDSPlot(G, hAxes, e);

            % Add this callback after every component is made
            obj.Figure.SizeChangedFcn = @(s, e) obj.onFigureSizeChanged;
            obj.Figure.CloseRequestFcn = @obj.onExit;
            
            obj.Figure.WindowKeyPressFcn = @obj.onKeyPressed;
            
            obj.SchemaMenu = om.SchemaMenu(obj, {'openminds.core'});
            obj.SchemaMenu.MenuSelectedFcn = @obj.onSchemaMenuItemSelected;
            
            obj.changeSelection('Subject')
            
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

            delete(obj.Figure)

        end

        function onExit(obj, src, evt)
            obj.saveMetadataSet()

            windowPosition = obj.Figure.Position;
            setpref('openMINDS', 'WindowSize', windowPosition)

            delete(obj)
        end

    end

    methods %Set / get 
        function saveFolder = get.SaveFolder(~)
            saveFolder = fullfile(userpath, 'openMINDS', 'userdata');
            if ~isfolder(saveFolder); mkdir(saveFolder); end
        end
    end

    methods

        function changeSelection(obj, schemaName)
            obj.UISideBar.SelectedItems = schemaName;
        end
        
        function onKeyPressed(obj, src, evt)

        end

        function onSelectionChanged(obj, src, evt)
            schemaName = src.Tag;

            % check if schema has a table
            metaTable = obj.MetadataSet.getTable(schemaName);

            if ~isempty(metaTable)
                %obj.UIMetaTableViewer.resetTable()
                obj.UIMetaTableViewer.refreshTable(metaTable, true)
            else
                obj.UIMetaTableViewer.resetTable()
                obj.UIMetaTableViewer.refreshTable(table.empty, true)
            end
        end

        function onFigureSizeChanged(app)
            app.updateLayoutPositions()
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

    methods (Access = private)
        
        function createTabGroup(obj)
            
            obj.UIContainer.UITab = gobjects(0);

            for i = 1:numel(obj.Pages)
                
                pageName = obj.Pages{i};
                
                hTab = uitab(obj.UIContainer.TabGroup);
                hTab.Title = pageName;

                obj.UIContainer.UITab(i) = hTab;
            end


        end

        function saveMetadataSet(obj)
            metadataSetPath = fullfile(obj.SaveFolder, 'metadata_set.mat');
            S = struct;
            S.metadataSet = obj.MetadataSet;
            save(metadataSetPath, '-struct', 'S')
        end

        function loadMetadataSet(obj)
            metadataSetPath = fullfile(obj.SaveFolder, 'metadata_set.mat');
            if isfile(metadataSetPath)
                S = load(metadataSetPath, 'metadataSet');
                obj.MetadataSet = S.metadataSet;
            else
                obj.MetadataSet = om.MetadataSet();
            end
        end

        function onSchemaMenuItemSelected(obj, functionName, selectionMode)
 
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

            

            % If we got this far, we are creating a new schema
            itemFactory = str2func(functionName);
            newItem = arrayfun(@(i)itemFactory(), 1:n);

            [SOrig, SNew] = deal( newItem(1).toStruct );
            
            % Fill out options for each property
            propNames = fieldnames(SOrig);

            for i = 1:numel(propNames)
                iPropName = propNames{i};
                iPropName_ = [iPropName, '_'];
                iValue = SNew.(iPropName);

                if isenum(iValue)
                    [~, m] = enumeration( iValue );
                    SNew.(iPropName) = m{1};
                    SNew.(iPropName_) = m;
                elseif isstring(iValue)
                    SNew.(iPropName) = char(iValue);
                else

                end

            end

            [~, ~, className] = fileparts(functionName);
            [className, classNameLabel] = deal( className(2:end) );

            if n>1; classNameLabel = [className, 's']; end

            titleStr = sprintf('Create New %s', classNameLabel);
            promptStr = sprintf('Fill out properties for %s', classNameLabel);
            [SNew, wasAborted] = tools.editStruct(SNew, [], titleStr, 'Prompt', promptStr);

            if wasAborted; return; end
                
            for i = 1:numel(propNames)
                iPropName = propNames{i};
                iValue = SOrig.(iPropName);

                if isenum(iValue)
                    enumFcn = str2func( class(iValue) );
                    SNew.(iPropName) = enumFcn(SNew.(iPropName));
                elseif isstring(iValue)
                    SNew.(iPropName) = char(SNew.(iPropName));
                end
            end


            for i = 1:numel(newItem)
                newItem(i).fromStruct(SNew)
            end
            
            obj.MetadataSet.add(newItem)

            % Todo: update tables...!

            obj.changeSelection(className)
        end

    end

    methods (Static)
        function clearMetadataSet()
            saveFolder = fullfile(userpath, 'openMINDS', 'userdata');
            metadataSetPath = fullfile(saveFolder, 'metadata_set.mat');
            if isfile(metadataSetPath)
                delete(metadataSetPath)
            end
        end
    end
end
