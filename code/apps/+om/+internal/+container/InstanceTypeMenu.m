classdef InstanceTypeMenu < handle & matlab.mixin.SetGet
% InstanceTypeMenu Provides a context menu for selecting openMINDS types

    properties (SetAccess = private)
        Types (1,:) om.enum.Types
    end

    properties
        SelectedType (1,1) om.enum.Types
        SelectionChangedFcn
    end
    
    properties (Access = private)
        UIContextMenu
    end

    methods % Constructor
        function obj = InstanceTypeMenu(hFigure, options)
            arguments
                hFigure matlab.ui.Figure
                options.?om.internal.container.InstanceTypeMenu
                options.Types (1,:) om.enum.Types
            end

            if isfield(options, 'Types')
                obj.Types = options.Types;
                obj.createContextMenu(hFigure)
                options = rmfield(options, 'Types');
            end

            obj.set(options)
        end
    end

    methods
        function open(obj, x, y)
            obj.UIContextMenu.open(x, y)
        end
    end

    methods 
        function set.SelectedType(obj, value)
            value = obj.validateActiveType(value);
            obj.SelectedType = value;
            obj.postSetSelectedType()
        end
    end

    methods (Access = private)
        function postSetSelectedType(obj)
            obj.updateCheckedContextMenuItem()
            if ~isempty(obj.SelectionChangedFcn)
                evtData = om.internal.event.SelectedTypeChangedData(obj.SelectedType);
                obj.SelectionChangedFcn(obj, evtData)
            end
        end
    end

    methods (Access = private)

        % Create context menu for selecting active type
        function createContextMenu(obj, hFigure)
        % createContextMenu - Create context menu for selecting active type

            if ~isempty(hFigure) && isvalid(hFigure)
                if isempty(obj.UIContextMenu)
                    obj.UIContextMenu = uicontextmenu(hFigure);
                end
                
                if ~isempty(obj.UIContextMenu.Children)
                    delete(obj.UIContextMenu.Children)
                end

                for i = 1:numel(obj.Types)
                    typeName = obj.Types(i).getSchemaName();
                    typeMenuItem = uimenu(obj.UIContextMenu);
                    typeMenuItem.Text = typeName;
                    typeMenuItem.Callback = @obj.onContextMenuItemClicked;
                    typeMenuItem.Checked = 'off';
                end
            end
        end

        function updateCheckedContextMenuItem(obj)
            % Uncheck all menu items
            set(obj.UIContextMenu.Children, 'Checked', 'off');

            if ismissing(obj.SelectedType)
                % pass
            else
                menuItemLabels = {obj.UIContextMenu.Children.Text};
                selectedTypeName = obj.SelectedType.getSchemaName();

                isMatch = strcmp(menuItemLabels, selectedTypeName);
                if any(isMatch)
                    obj.UIContextMenu.Children(isMatch).Checked = "on";
                else
                    error('Unexpected')
                end
            end
        end

        function onContextMenuItemClicked(obj, ~, event)
            obj.SelectedType = om.enum.Types(event.Source.Text);
        end
        
        function value = validateActiveType(obj, value)
        % validateActiveType - Validate value for ActiveType property

            isValid = any( obj.Types == value );
            
            errorMessage = sprintf( 'Selected type must be any of: %s', ...
                    strjoin(string(obj.Types), ', '));

            assert(isValid, errorMessage)
        end
    end
end