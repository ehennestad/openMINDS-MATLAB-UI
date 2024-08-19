classdef InstanceDropDown < matlab.ui.componentcontainer.ComponentContainer

    % Todo: 
    %   [ ] Add "mixin.Chameleon" (i.e use same background color as parent
    %   [ ] Only show download action if remote metadata collection is
    %       assigned
    %   [ ] Add listener for Metadata collection events 

    % Notes:
    % For efficiency, the dropdown is only populated with items, the
    % ItemsData is only represented in this class. For thousands of items +
    % itemsdata, dropdowns are very slow to update when changing items and
    % itemsdata, which is necessary if implementing filtering and
    % modifications of items/itemsdata (TODO)


    % Properties that correspond to underlying components
    properties (Access = private, Transient, NonCopyable)
        GridLayout  matlab.ui.container.GridLayout
        DropDown    matlab.ui.control.DropDown
    end

    % Events with associated public callbacks
    events (HasCallbackProperty, NotifyAccess = private)
        ValueChanged
    end

    properties (SetAccess = private)
        Items (1,:) string = string.empty;
        ItemsData (1,:) cell = {};
    end

    properties
        Value % NB: Need public set access
    end
    
    properties (Constant)
        Actions = ["*Select a instance*", "*Create a new instance*", "*Download instances*"]
    end

    properties (SetAccess = private)
        MetadataCollection
        RemoteMetadataCollection
    end

    properties (SetAccess = private)
        UpstreamInstanceType (1,1) string = missing
        UpstreamInstancePropertyName (1,1) string = missing
    end

    properties (AbortSet = true)
        % MetadataType - The metadata type which is currently active/selected 
        % in this component
        MetadataType (1,1) om.enum.Types = "None"
    end

    properties (Access = private)
        % HasRemoteInstances - Boolean flag indicating whether dropdown is
        % populated with remote instances (instances from a remote metadata 
        % collection)
        HasRemoteInstances = false

        SearchField
        SearchString = ''

        ItemsStore
        ItemsDataStore
    end

    methods
        function comp = InstanceDropDown(propValues)
            arguments
                propValues.?matlab.ui.control.DropDown
                propValues.CreateFcn % ComponentContainer property
                propValues.MetadataCollection
                propValues.MetadataType (1,1) om.enum.Types = "None"
                propValues.UpstreamInstanceType (1,1) string = missing
                propValues.UpstreamInstancePropertyName (1,1) string = missing
                propValues.RemoteMetadataCollection
            end

            [propValues, propValuesSuper] = popPropValues(propValues, 'Parent', 'CreateFcn', 'Position');
            comp@matlab.ui.componentcontainer.ComponentContainer(propValuesSuper)

            % Assign metadata collection and type
            [propValues, propValuesMetadata] = popPropValues(propValues, ...
                'MetadataCollection', 'RemoteMetadataCollection', 'MetadataType');
            % NB: In order to correctly initialize, MetaDataType needs to
            % be set last, hence it is last input in function call above.
            set(comp, propValuesMetadata)

            % Assign upstream instance information
            [propValues, propValuesUpstream] = popPropValues(propValues, ...
                'UpstreamInstanceType', 'UpstreamInstancePropertyName');
            set(comp, propValuesUpstream)

            % break out Items and ItemsData (Todo: Not needed)
            [propValues, propValuesItems] = popPropValues(propValues, 'Items', 'ItemsData');
            
            % Set items and itemsdata...

            % Assign property values to dropdown
            set(comp.DropDown, propValues)

            % Initialize filter functionality
            % (Not functional yet)
            % comp.createFilter()
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
            if isempty(comp.RemoteMetadataCollection)
                actions = actions(1:2);
            end
            items = [actions, comp.Items];
            comp.DropDown.Items = items;

            %s1 = uistyle("Icon", om.internal.getIconPath('id_none-34-32'), "IconAlignment", 'leftmargin', "HorizontalAlignment", 'center', "FontWeight", "bold");
            s2 = uistyle("Icon", om.internal.getIconPath('id_create-v-32'));
            s3 = uistyle("Icon", om.internal.getIconPath('id_download-download-3-32'));

            %s1 = uistyle("FontWeight", "bold", "FontColor", [0.3,0.3,0.3]);
            % s1 = uistyle("FontAngle", "italic", "FontColor", [0.15,0.15,0.15]);
            % 
            % addStyle(comp.DropDown,s1,"item",1);
            % addStyle(comp.DropDown,s1,"item",2);
            % addStyle(comp.DropDown,s1,"item",3);
        end
                
        function postSetItemsData(comp)
            % Build items for actions.
            if comp.MetadataType == om.enum.Types.None
                emptyInstance = [];
            else
                emptyInstance = feval( sprintf("%s.empty", comp.MetadataType.ClassName));
            end
            if isempty(comp.RemoteMetadataCollection)
                actionItems = [{emptyInstance}, cellstr(comp.Actions(2))];
            else
                actionItems = [{emptyInstance}, cellstr(comp.Actions(2:3))];
            end

            itemsData = [actionItems, comp.ItemsData];
            comp.DropDown.ItemsData = itemsData;
        end

        function postSetMetadataType(comp)
            comp.updateDropdownItems()
        end

        function postSetRemoteMetadataCollection(comp)
            % Get instances of dropdown type...
            
            %comp.postSetItems()
            %comp.postSetItemsData()
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
                end
                if ~wasSuccess % Reset dropdown selection
                    comp.DropDown.Value = comp.Value;
                end
            else
                comp.updateValue(value, event.PreviousValue)
            end
        end

        function onDropDownOpened(comp, src, evt)
            comp.SearchString = '';
            comp.DropDown.Tooltip = comp.SearchString;
            comp.Items = comp.Items;
            if ~isempty(comp.ItemsStore)
                %comp.Items = comp.ItemsStore;
                %comp.ItemsData = comp.ItemsDataStore;
                %comp.ItemsStore = [];
                %comp.ItemsDataStore = [];
            end

            comp.SearchField.Value = comp.SearchString;
            comp.SearchField.Visible = true;
            %focus()
        end

        function onKeyPressed(comp, src, evt)
            disp(src.CurrentObject)
            if src.CurrentObject == comp.DropDown
                if string(evt.Key) == "backspace"
                    if numel(comp.SearchString) >= 1
                        comp.SearchString = comp.SearchString(1:end-1);
                    else
                        comp.SearchString = '';
                    end
                elseif ~isempty(regexp(evt.Character, '\w', 'once'))
                    comp.SearchString = [comp.SearchString, evt.Key];
                end

                if isempty(comp.ItemsStore)
                    comp.ItemsStore = comp.Items;
                    comp.ItemsDataStore = comp.ItemsData;
                end
                disp(comp.SearchString)

                isMatch = contains(comp.Items, comp.SearchString, 'IgnoreCase', true);
                
                %comp.Items = comp.ItemsStore(isMatch);
                %comp.ItemsData = comp.ItemsDataStore(isMatch);

                if ~isempty(comp.SearchString)
                    comp.DropDown.ItemsData = {};
                    comp.DropDown.Items = comp.Items(isMatch);
                   % comp.DropDown.Value = comp.DropDown.Items{1};
                    comp.SearchField.Visible = true;

                    %comp.DropDown.Items{1} = comp.SearchString;
                    
                    % if ~isempty(comp.ItemsData)
                    %     comp.Value = comp.ItemsData{1};
                    % else
                    %     comp.Value = comp.DropDown.ItemsData{1};
                    % end
                else
                    %comp.DropDown.Items = comp.Items;
                    tic
                    comp.Items = comp.Items;
                    toc
                    %comp.DropDown.Value = comp.DropDown.Items{1};
                    comp.SearchField.Visible = false;

                    %comp.ItemsData = comp.ItemsData;
                end
                comp.SearchField.Value = comp.SearchString;
                comp.DropDown.Tooltip = comp.SearchString;
            end
            
            % Todo...
        end
    
        function onMousePressed(comp, src, evt)
            if src.CurrentObject == comp.DropDown

            else
                comp.SearchField.Visible = false;
            end
        end
    
    end

    methods (Access = private)
        
        function createFilter(comp)
            comp.DropDown.DropDownOpeningFcn = @comp.onDropDownOpened;
            
            comp.SearchField = uieditfield(comp.GridLayout);
            comp.SearchField.Layout.Column = comp.DropDown.Layout.Column;
            comp.SearchField.Layout.Row = comp.DropDown.Layout.Row;
            comp.SearchField.Visible = false;
            comp.SearchField.Placeholder = "Type to search...";

            hFigure = ancestor(comp, 'figure');
            addlistener(hFigure, 'WindowKeyPress', @comp.onKeyPressed);
            addlistener(hFigure, 'WindowMousePress', @comp.onMousePressed);
        end

        function updateDropdownItems(comp)
            items = string.empty;
            itemsData = {};

            if ismissing(comp.MetadataType)
                % pass
            else
                
                %schemaName = openminds.internal.utility.getSchemaShortName(comp.ActiveType);
                %typeClassName = comp.MetadataType.ClassName;
                
                metadataType = string(comp.MetadataType);
                itemsData = comp.MetadataCollection.list( metadataType );

                if ~isempty(comp.RemoteMetadataCollection)
                    remoteInstances = comp.RemoteMetadataCollection.list( metadataType );
                    if ~isempty(remoteInstances)
                        itemsData = [itemsData, remoteInstances];
                        comp.HasRemoteInstances = true;
                    end
                end

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

            actions = strrep(actions, 'instance', sprintf('%s instance', lower(label)));
            if startsWithVowel
                actions = strrep(actions, 'Select a', 'Select an');
            end

            if comp.HasRemoteInstances
                actions = strrep(actions, 'Download', 'Synch');
            end
                            
            actions = strrep(actions, ' instances', '');
            actions = strrep(actions, ' instance', '');

            %actions = string( compose('%s', actions) );
        end
    end

    methods (Access = private)
    
        function wasSuccess = createNewInstance(comp)
            wasSuccess = false;

            emptyInstance = feval(comp.MetadataType);

            schemaName = om.internal.vocab.getSchemaNameFromMixedTypeClassName(comp.MixedTypeClassName);
            schemaClassName = om.internal.vocab.getFullClassNameFromSchemaName(schemaName);

            propertyName = char( openminds.internal.utility.getSchemaShortName( comp.MixedTypeClassName ) );
            propertyName(1) = lower(propertyName(1));

            %propertyTypeName = eval(sprintf("%s.X_TYPE", schemaClassName)) + "/" + propertyName;

            [itemData, item] = om.uiCreateNewInstance(emptyInstance, comp.MetadataCollection );

            if isempty(itemData)
                return
            else
                
                comp.Items = [comp.Items, item];
                comp.ItemsData = [comp.ItemsData, {itemData}];
                drawnow
                comp.Value = itemData;

                wasSuccess = true;
            end
        end
        
        function wasSuccess = downloadRemoteInstances(comp)
            try
                activeType = comp.MetadataType;
    
                % Create a progress bar
                hFigure = ancestor(comp, 'figure');
                hProgress = uiprogressdlg(hFigure, 'Message', 'Downloading instances...', 'Indeterminate', true);
    
                comp.RemoteMetadataCollection.downloadRemoteInstances(activeType, 'ProgressDialog', hProgress)
                comp.updateDropdownItems()
                wasSuccess = true;
            catch
                wasSuccess = false;
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
