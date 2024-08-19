classdef InstanceTypeMenu < handle & matlab.mixin.SetGet
    
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
        function [obj, cmenu] = InstanceTypeMenu(hFigure, options)
            arguments
                hFigure matlab.ui.Figure
                options.?om.internal.container.InstanceTypeMenu
                options.Types (1,:) om.enum.Types
            end
            obj.set(options)
            obj.createContextMenu(hFigure)
            cmenu = obj.UIContextMenu;
        end
    end

    methods 
        function set.SelectedType(comp, value)
            value = comp.validateActiveType(value);
            comp.SelectedType = value;
            comp.postSetSelectedType()
        end
    end

    methods (Access = private)
        function postSetSelectedType(comp)
            comp.updateCheckedContextMenuItem()
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
                    iType = obj.Types(i).ClassName;
                    typeShortName = openminds.internal.utility.getSchemaShortName(iType);

                    typeMenuItem = uimenu(obj.UIContextMenu);
                    typeMenuItem.Text = typeShortName;
                    typeMenuItem.Callback = @obj.onContextMenuItemClicked;
                    typeMenuItem.Checked = 'off';
                end
            end
        end

        function updateCheckedContextMenuItem(comp)
            % Uncheck all menu items
            set(comp.UIContextMenu.Children, 'Checked', 'off');

            if ismissing(comp.SelectedType)
                % pass
            else
                menuItemLabels = {comp.UIContextMenu.Children.Text};
                selectedTypeName = comp.SelectedType.getSchemaName();

                isMatch = strcmp(menuItemLabels, selectedTypeName);
                if any(isMatch)
                    comp.UIContextMenu.Children(isMatch).Checked = "on";
                else
                    error('Unexpected')
                end
            end
        end

        function onContextMenuItemClicked(comp, src, event)

            %comp.SelectedItem = [];
            
            fullClassName = om.enum.Types(event.Source.Text).ClassName;
            disp(fullClassName)
            %fullClassName = comp.findMatchingClassName(event.Source.Text, comp.AllowedTypes);
            comp.SelectedType = om.enum.Types(event.Source.Text);
        end
        
        function value = validateActiveType(comp, value)
        % validateActiveType - Validate value for ActiveType property

            isValid = any( comp.Types == value );
            
            errorMessage = sprintf( 'Selected type must be any of: %s', ...
                    strjoin(string(comp.Types), ', '));

            assert(isValid, errorMessage)
        end
    end
end