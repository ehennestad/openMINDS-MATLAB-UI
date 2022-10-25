classdef ListBox < handle


    properties
        Items
        SelectionChangedFcn
    end

    properties (Access = private)
        Name
        Icon
    end

    properties % Appearance
        FontName = 'helvetica';
    end

    properties (SetAccess = private)
        Panel
        Buttons uim.control.Button_
        ButtonCollection uim.widget.toolbar_
    end

    properties (Access = private)
        SelectedButtons
    end

%     properties (Constant, Hidden = true) % Move to appwindow superclass
%         ICONS = uim.style.iconSet(structeditor.App.getIconPath)
%     end

    methods
        
        function obj = ListBox(hPanel, items)
            
            obj.Items = items;

            if isa(items, 'cell')
                obj.Name = items;
                obj.Icon = cell(size(obj.Name));
            elseif isa(items, 'struct')
                obj.Name = items.Name;
                obj.Icon = items.Icon;
            end

            buttonWidth = 160;
            xPad = 2;

            obj.Panel = hPanel;
            
            hToolbar = uim.widget.toolbar_(obj.Panel, 'Location', 'northwest', ...
                'Margin', [0,0,0,10],'ComponentAlignment', 'top', ...
                'BackgroundAlpha', 0, 'IsFixedSize', [true, false], ...
                'NewButtonSize', [buttonWidth, 25], 'Padding', [0,10,0,10], ...
                'Spacing', 0);

            buttonConfig = {'FontSize', 15, 'FontName', obj.FontName, ...
                'Padding', [xPad,2,xPad,2], 'CornerRadius', 0, ...
                'Mode', 'togglebutton', 'Style', uim.style.tabButtonLight, ...
                'IconSize', [12,12], 'IconTextSpacing', 7};
            
            % Bug with toolbar so buttons are created from the bottom up
            counter = 0;
            for i = numel(obj.Name):-1:1
                counter = counter+1;
                
                thisName = obj.Name{i};
                thisIcon = obj.Icon{i};


%                 if any(strcmpi(obj.ICONS.iconNames, obj.Name{i}) )
%                     icon = obj.ICONS.(lower(obj.Name{i}));
%                 else
%                     icon = obj.ICONS.default;
%                 end

                obj.Buttons(counter) = hToolbar.addButton(...
                    'Text', utility.string.varname2label(thisName), 'Icon', thisIcon, ...
                    'Callback', @(s,e,n) obj.onListButtonPressed(s,e,i), ...
                    'Tag', thisName, buttonConfig{:} );
                if i == 1
                    obj.Buttons(counter).Value = true;
                end
            end
            
            obj.ButtonCollection = hToolbar;
            hToolbar.Location = 'northwest';

        end
    end


    methods (Access = private)

        function onListButtonPressed(obj, src, evt, idx)

            triggerCallback = false;
            
            disp(evt.Source.SelectionType)
            switch evt.Source.SelectionType
                case 'normal'
                    % Clicked button which is already selected
                    if isequal(obj.SelectedButtons, src)
                        src.Value = true;
                        return
                    end
                    
                    % Make sure other buttons are unselected
                    if ~isempty(obj.SelectedButtons)
                        for i = 1:numel(obj.SelectedButtons)
                            if isequal(obj.SelectedButtons(i), src)
                                obj.SelectedButtons(i).Value = true;
                            else
                                obj.SelectedButtons(i).Value = false;
                                triggerCallback = true;
                            end
                        end
                    end

                    obj.SelectedButtons = src;

                case 'extend'
                    
                    if any(obj.SelectedButtons == src)
                        src.Value = true;
                        return
                    else
                        obj.SelectedButtons = [obj.SelectedButtons, src];
                        triggerCallback = true;
                    end
                    
                case 'open'
                
                
            end

            buttonNames = {obj.SelectedButtons.Text};
            fprintf('Selected buttons: %s\n', strjoin(buttonNames, ', '))


            % Call the SelectionChangedFcn if preset...
            if ~isempty(obj.SelectionChangedFcn) && triggerCallback
                disp('Selection Changed')
                obj.SelectionChangedFcn(src, evt)
            end



            % Notify listeners.
            % - What listeners?
        end


    end
end