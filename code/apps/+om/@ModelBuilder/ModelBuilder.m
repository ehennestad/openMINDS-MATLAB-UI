classdef ModelBuilder < handle
    
    properties
        MetadataInstance
        MetadataSet
    end

    properties % UI Properties
        Figure
        UIPanel
        UIMetaTableViewer
    end
    
% Create figure

    methods

        function obj = ModelBuilder(metadataSet, metaTable)
            
            obj.MetadataSet = metadataSet;
            
            W = 1000;
            H = 600;
            hFigure = figure('Position', [100,100,W,H], 'MenuBar','figure', 'ToolBar','none');
            obj.Figure = hFigure;
            
            obj.UIPanel.Toolbar = uipanel(hFigure);
            obj.UIPanel.SidebarL = uipanel(hFigure);
            obj.UIPanel.Table = uipanel(hFigure);
                        
            panels = [obj.UIPanel.Toolbar, obj.UIPanel.SidebarL, obj.UIPanel.Table];
            set(panels, 'Units', 'pixels', 'BackgroundColor', 'w', 'BorderType','etchedin')

            obj.updateLayoutPositions()

            sideBar = om.gui.control.ListBox(obj.UIPanel.SidebarL, {'Subject', 'TissueSample', 'SubjectState', 'TissueSampleState'});
            sideBar.SelectionChangedFcn = @obj.onSelectionChanged;
            
            %metaTable = [];
            %pathStr = nansen.metadata.MetaTableCatalog.getDefaultMetaTablePath();
            %metaTable = nansen.metadata.MetaTable.open(pathStr);
            
            columnSettings = obj.loadMetatableColumnSettings();
            nvPairs = {'ColumnSettings', columnSettings};

            h = nansen.MetaTableViewer( obj.UIPanel.Table, metaTable, nvPairs{:});
            obj.UIMetaTableViewer = h;

            % Add this callback after every component is made
            obj.Figure.SizeChangedFcn = @(s, e) obj.onFigureSizeChanged;
            obj.Figure.CloseRequestFcn = @obj.onExit;
            
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
            delete(obj)
        end

    end


    methods 

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

            obj.UIPanel.Toolbar.Position = [MARGIN,H-MARGIN-toolH,W-MARGIN*2,toolH];
            
            h = H-MARGIN*2-toolH-PADDING;
            w = 150;
            obj.UIPanel.SidebarL.Position = [MARGIN,MARGIN,w,h];
            obj.UIPanel.Table.Position = [w+MARGIN+PADDING, MARGIN, W-MARGIN*2-w-PADDING, h];
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
end
