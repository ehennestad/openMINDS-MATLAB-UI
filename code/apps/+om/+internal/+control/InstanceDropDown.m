classdef InstanceDropDown < matlab.ui.componentcontainer.ComponentContainer

    % Todo: 
    %   [ ] Add "mixin.Chameleon" (i.e use same background color as parent
    %   [ ] Only show download action if remote metadata collection is
    %       assigned
    %   [ ] Test functionality when EditItemsFcn is assigned
    %   [ ] Add listener for Metadata collection events 

    % Properties that correspond to underlying components
    properties (Access = private, Transient, NonCopyable)
        GridLayout  matlab.ui.container.GridLayout
        DropDown    matlab.ui.control.DropDown
    end

    % Events with associated public callbacks
    events (HasCallbackProperty, NotifyAccess = private)
        ValueChanged
    end

    properties (Access = public)
        EditItemsFcn
        Items (1,:) string = string.empty; % Todo: Is this settable?
        ItemsData (1,:) cell = {}; % Todo: Is this settable?
        Value
    end

    properties (Constant)
        Actions = ["<Select a instance>", "<Create a new instance>", "<Download instances>"]
    end

    properties (SetAccess = immutable)
        MetadataCollection
        RemoteMetadataCollection
    end

    properties (AbortSet = true)
        % MetadataType - The metadata type which is currently active/selected 
        % in this component
        MetadataType (1,1) om.enum.Types = "None"
    end

    methods
        function comp = InstanceDropDown(propValues)
            arguments
                propValues.?matlab.ui.control.DropDown
                propValues.CreateFcn % ComponentContainer property
                propValues.MetadataCollection
                propValues.MetadataType (1,1) om.enum.Types = "None"
            end

            [propValues, propValuesSuper] = popPropValues(propValues, 'Parent', 'CreateFcn', 'Position');
            comp@matlab.ui.componentcontainer.ComponentContainer(propValuesSuper)

            % Assign metadata collection and type
            [propValues, propValuesMetadata] = popPropValues(propValues, 'MetadataCollection', 'MetadataType');
            comp.MetadataCollection = propValuesMetadata.MetadataCollection;
            comp.MetadataType = propValuesMetadata.MetadataType;

            % break out Items and ItemsData
            [propValues, propValuesItems] = popPropValues(propValues, 'Items', 'ItemsData');
            
            
            % Assign property values to dropdown
            set(comp.DropDown, propValues)

        end
    end

    methods
        function updateValue(comp, newValue, previousValue)
            comp.Value = newValue;

            evtData = matlab.ui.eventdata.ValueChangedData(...
                newValue, previousValue);

            notify(comp, 'ValueChanged', evtData);
        end
    end

    % Property set methods
    methods
        function set.Value(comp, value)
            comp.Value = value;
            comp.postSetValue()
        end

        function set.Items(comp, value)
            comp.Items = value;
            comp.postSetItems()
        end
               
        function set.ItemsData(comp, value)
            comp.ItemsData = value;
            comp.postSetItemsData()
        end

        function set.MetadataType(comp, value)
            %value = comp.validateMetadataType(value);
            if strcmp(comp.MetadataType, value); return; end
            comp.MetadataType = value;
            comp.postSetMetadataType()
        end
    end

    % Property post-set methods
    methods (Access = private)
        function postSetValue(comp)
            if isempty(comp.Value)
                % Make sure the empty instance in ItemsData is the same 
                % object (handle) as the current Value
                if strcmp( class(comp.Value), class(comp.DropDown.ItemsData{1}) )
                    comp.DropDown.ItemsData{1} = comp.Value;
                end
            end
            
            comp.DropDown.Value = comp.Value;
        end

        function postSetItems(comp)
            actions = comp.getActionsWithTypeLabels();
            items = [actions, comp.Items];
            comp.DropDown.Items = items;
        end
                
        function postSetItemsData(comp)
            % Build items for actions.
            if ~ismissing(comp.MetadataType)
                emptyInstance = feval( sprintf("%s.empty", comp.MetadataType.ClassName));
                %emptyInstance = feval( sprintf("%s.empty", comp.MixedTypeClassName) );
            else
                emptyInstance = [];
            end
            actionItems = [{emptyInstance}, cellstr(comp.Actions(2:3))];

            itemsData = [actionItems, comp.ItemsData];
            comp.DropDown.ItemsData = itemsData;
        end

        function postSetMetadataType(comp)
            comp.updateDropdownItems()
        end
    end

    methods (Access = protected)
        
        % Code that executes when the value of a public property is changed
        function update(comp)
            % Use this function to update the underlying components
        end

        % Create the underlying components
        function setup(comp)

            comp.Position = [1 1 100 22];
            comp.BackgroundColor = [0.94 0.94 0.94];

            % Create GridLayout
            comp.GridLayout = uigridlayout(comp);
            comp.GridLayout.ColumnWidth = {'1x'};
            comp.GridLayout.RowHeight = {'1x'};
            comp.GridLayout.Padding = [0 0 0 0];

            % Create DropDown
            comp.DropDown = uidropdown(comp.GridLayout);
            comp.DropDown.Layout.Row = 1;
            comp.DropDown.Layout.Column = 1;
            comp.DropDown.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @DropDownValueChanged, true);
        end
    end

    % Component callbacks
    methods (Access = private)
        % Value changed function: DropDown
        function DropDownValueChanged(comp, event)
            value = comp.DropDown.Value;
            
            if isequal(value, comp.Actions(2)) || isequal(value, comp.Actions(3))
                switch value
                    case comp.Actions(2)
                        wasSuccess = comp.createNewInstance();
                    case comp.Actions(3)
                        wasSuccess = comp.downloadRemoteInstances();
                        comp.DropDown.Value = comp.Value;
                end
                if ~wasSuccess % Reset dropdown selection
                    comp.DropDown.Value = comp.Value;
                end
            else
                comp.updateValue(value, event.PreviousValue)
            end
        end
    end

    methods (Access = private)
        
        function updateDropdownItems(comp)
            items = string.empty;
            itemsData = {};

            if ismissing(comp.MetadataType)
                % pass
            else
                
                %schemaName = openminds.internal.utility.getSchemaShortName(comp.ActiveType);
                %typeClassName = comp.MetadataType.ClassName;
                
                itemsData = comp.MetadataCollection.list( string(comp.MetadataType) );
                if ~isempty(itemsData)
                    items = arrayfun(@(i) string(char(i)), itemsData);
                end
                itemsDataCell = cell(1, numel(itemsData));
                for i = 1:numel(itemsData)
                    %itemsDataCell{i} = feval(comp.MixedTypeClassName, itemsData(i));
                end
                %itemsData = itemsDataCell;

            end
            comp.Items = items;
            comp.ItemsData = num2cell(itemsData);
        end

        function actions = getActionsWithTypeLabels(comp)
            actions = comp.Actions;

            if ismissing(comp.MetadataType)
                return
            end
            
            %activeTypeShortName = openminds.internal.utility.getSchemaShortName(comp.MetadataType);
            
            typeName = string(comp.MetadataType);

            % Get label from vocab
            label = om.internal.vocab.getSchemaLabelFromName(typeName);

            vowels = 'aeiouy';
            label = char(label);
            startsWithVowel = any( label(1) == vowels );

            actions = strrep(actions, 'instance', sprintf('"%s" instance', lower(label)));
            if startsWithVowel
                actions = strrep(actions, 'Select a', 'Select an');
            end
        end
    end
end

function [propValues, propValuesPopped] = popPropValues(propValues, varargin)
    propValuesPopped = struct;
    for i = 1:numel(varargin)
        if isfield(propValues, varargin{i})
            propValuesPopped.(varargin{i}) = propValues.(varargin{i});
            propValues = rmfield(propValues, varargin{i});
        end
    end
end
