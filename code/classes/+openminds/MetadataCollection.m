classdef MetadataCollection < handle
    
    
    % Questions:
    % What to use for keys in the metadata map
    %    - Short name; i.e Subject
    %    - Class name; i.e openminds.core.Subject
    %    - openMINDS type; i.e https://openminds.ebrains.eu/core/Subject
    

    % TODO:
    %   - [ ] Remove instances
    %   - [ ] Modify instances
    %   - [ ] Get instance
    %   - [ ] Get all instances of type

    %   - [ ] Add dynamic properties for each type in the collection?
    
    % Public properties:
    properties

        
    end

    properties (Access = public)
        metadata containers.Map
        graph digraph = digraph
    end

    
    events
        CollectionChanged
        InstanceAdded
        InstanceRemoved
        InstanceModified
        %TableUpdated ???
        %GraphUpdated ???
    end

    
    methods
        function obj = MetadataCollection()
            obj.metadata = containers.Map;
            obj.graph = digraph;
        end
        
        function add(obj, metadataInstance)
            
            import openminds.metadatacollection.event.CollectionChangedEventData

            instanceClass = class(metadataInstance);
            instanceName = obj.getSchemaShortName(instanceClass);
            
            if isKey(obj.metadata, instanceName)
                obj.metadata(instanceName) = [obj.metadata(instanceName), metadataInstance];
            else
                obj.metadata(instanceName) = metadataInstance;
            end

            for i = 1:numel(metadataInstance)
                
                thisInstance = metadataInstance(i);
                
                if ~isempty(obj.graph.Nodes)
                    foundNode = findnode(obj.graph, thisInstance.id);
                else
                    foundNode = 0;
                end

                if foundNode == 0
                    obj.graph = addnode(obj.graph, thisInstance.id);
                    obj.createInstanceListeners(thisInstance)
                end

                % Don't loop through controlled terms properties

                if isa(thisInstance, 'openminds.controlledterms.ControlledTerm')
                    continue
                end

                obj.addInstanceProperties(thisInstance)
            end

            evtData = CollectionChangedEventData('INSTANCE_ADDED', metadataInstance);
            obj.notify('CollectionChanged', evtData)
        end

        function remove(obj, metadataName)
            obj.metadata.remove(metadataName);
            obj.graph = rmnode(obj.graph, metadataName);
        end

        function removeInstance(obj, type, index)
            instancesOfType = obj.metadata(type);
            instancesOfType(index)=[];
            obj.metadata(type) = instancesOfType;
        end

        function modifyInstance(obj, type, index, propName, propValue)
            instancesOfType = obj.metadata(type);
            instancesOfType(index).(propName)=propValue;
            obj.metadata(type) = instancesOfType;
        end

        function updateMetadata(obj)
            % Update all metadata
        end

        function createListenersForAllInstances(obj)
        
            keyNames = obj.metadata.keys();

            for i = 1:numel(keyNames)
                instances = obj.metadata(keyNames{i});
                for j = 1:numel(instances)
                    if isa(instances(j), 'openminds.controlledterms.ControlledTerm')
                        continue
                    else
                        obj.createInstanceListeners(instances(j))
                    end
                end
            end
        end

        function createInstanceListeners(obj, instance)
            addlistener(instance, 'InstanceChanged', @obj.onInstanceChanged);
            addlistener(instance, 'PropertyWithLinkedInstanceChanged', ...
                @obj.onPropertyWithLinkedInstanceChanged);
        end

        function labels = getSchemaInstanceLabels(obj, schemaName, schemaId)
            
            if nargin < 3; schemaId = ''; end

            schemaName = obj.getSchemaShortName(schemaName);
            schemaInstances = obj.getSchemaInstances(schemaName);
            
            numSchemas = numel(schemaInstances);

            labels = arrayfun(@(i) sprintf('%s-%d', schemaName, i), 1:numSchemas, 'UniformOutput', false);
            if ~isempty(schemaId)
                isMatchedInstance = strcmp({schemaInstances.id}, schemaId);
                labels = labels(isMatchedInstance);
            end
            
        end

        function schemaInstance = getInstanceFromLabel(obj, schemaName, label)
            labels = obj.getSchemaInstanceLabels(schemaName);
            isMatch = strcmp(labels, label);
            
            schemaInstances = obj.getSchemaInstances(schemaName);
            schemaInstance = schemaInstances(isMatch);
        end

        function schemaInstances = getSchemaInstances(obj, schemaName)
            
            if contains(schemaName, '.')
                schemaName = obj.getSchemaShortName(schemaName);
            end

            if isKey(obj.metadata, schemaName)
                schemaInstances = obj.metadata(schemaName);
            else
                schemaInstances = [];
            end
        end
        
        function schemaInstance = getSchemaInstanceByIndex(obj, schemaName, index)
            schemaInstances = obj.getSchemaInstances(schemaName);
            schemaInstance = schemaInstances(index);
        end

        function autoAssignLabels(obj, schemaName)
            % Update labels if they are empty...
            if isKey(obj.metadata, schemaName)
                labels = obj.getSchemaInstanceLabels(schemaName);
                instances = obj.SchemaInstances(schemaName);
                if isprop(instances, 'lookupLabel')
                    for i = 1:numel(instances)
                        if isempty(instances(i).lookupLabel) || strlength(instances(i).lookupLabel)==0
                            instances(i).lookupLabel = labels{i};
                        end
                    end
                end
            end
        end

    end

    methods (Access = private)

        function addInstanceProperties(obj, thisInstance)

            % Search through public properties of the metadata instance
            % for linked properties
            propertyNames = properties(thisInstance);

            for j = 1:length(propertyNames)
                propValue = thisInstance.(propertyNames{j});
                
                if isempty(propValue); continue; end

                if isa(propValue, 'openminds.abstract.Schema')
                    
                    if ~iscell(propValue)
                        % Recursively add the new type to the metadata property and the new node to the graph
                        for k = 1:length(propValue)
                            obj.add(propValue(k));

                            % Add the new node to the graph and an edge to the instance it is a property value of
                            obj.graph = addedge(obj.graph, thisInstance.id, propValue(k).id);
                        end
                    else
                        % Recursively add the new type to the metadata property and the new node to the graph
                        for k = 1:length(propValue)
                            obj.add(propValue{k});

                            % Add the new node to the graph and an edge to the instance it is a property value of
                            obj.graph = addedge(obj.graph, thisInstance.id, propValue{k}.id);
                        end
                    end
                end
            end
        end
    end

    methods (Access = private)

        function onPropertyWithLinkedInstanceChanged(obj, src, evt)
            
            % Todo: collect instance in evtdata
            obj.notify('InstanceModified', evt)
            fprintf('Linked instance of type %s was changed\n', class(src))

            removeIdx = find( strcmp(obj.graph.Edges.EndNodes(:,1), src.id) );

            obj.graph = rmedge(obj.graph, removeIdx);
            
            obj.addInstanceProperties(src)
        end

        function onInstanceChanged(obj, src, evt)
            
            obj.notify('InstanceModified', evt)
            fprintf('Instance of type %s was changed\n', class(src))
        end

    end


    methods % Methods for getting instances in table representations
        
        function metaTable = getTable(obj, schemaName)

            if isKey(obj.metadata, schemaName)
                schemaInstanceList = obj.metadata(schemaName);

                instanceTable = schemaInstanceList.toTable();
                instanceTable = obj.replaceLinkedInstancesWithCategoricals(instanceTable, schemaName);

                metaTable = nansen.metadata.MetaTable(instanceTable, 'MetaTableClass', class(schemaInstanceList));
            else
                metaTable = [];
            end
        end

        function metaTable = joinTables(obj, schemaNames, options)
            
            arguments
                obj
                schemaNames
                options.JoinMethod = 'join' % innerjoin , join, outerjoin
            end

            instanceLinkee = schemaNames{1};
            instanceLinked = schemaNames{2};

            tableLinker = obj.getTable(instanceLinkee).entries;
            tableLinker.id = {obj.metadata(instanceLinked).id}';
            tableLinked = obj.getTable(instanceLinked).entries;

            tableLinked.id = {obj.metadata(instanceLinked).id}';
            
            tableLinker = renamevars(tableLinker, 'lookupLabel', 'lookupLabel_Subject');
            tableLinked = renamevars(tableLinked, 'lookupLabel', 'lookupLabel_SubjectState');

            [leftKey, ~] = obj.getKeyPairsForJoin(instanceLinkee, instanceLinked);
            leftKey = 'id';
            rightKey = 'id';

            joinFcn = str2func(options.JoinMethod);

            joinedTable = joinFcn(tableLinker, tableLinked, 'LeftKeys', leftKey, 'RightKeys', rightKey);
            joinedTable.id = []; % Remove the id column

            joinedClassName = sprintf('%s * %s', instanceLinkee, instanceLinked);
            
            metaTable = nansen.metadata.MetaTable(joinedTable, 'MetaTableClass', joinedClassName);
        end

    end

    methods (Access = protected) % Methods for getting instances in table representations
        
        function [leftKey, rightKey] = getKeyPairsForJoin(obj, schemaNameLinker, schemaNameLinkee)
            
            
            disp('a')
            leftKey = 'studiedState';
            rightKey = 'id';

            % Who is linked from who.
            % Need to check the schema and find the name of the property
            % who is linked... What if many properties can be linked to the
            % same schema??

            % For the linkee : Use property name 
            %   Needed. List of linked properties and allowed link types

            % For the linked : Get id
        end
        
        function instanceTable = replaceLinkedInstancesWithCategoricals(obj, instanceTable, instanceType)

            [numRows, numColumns] = size(instanceTable);
            %tempStruct = table2struct(instanceTable(1,:));
            
            for i = 1:numColumns
                thisColumnName = instanceTable.Properties.VariableNames{i};

                % Todo: Check if columnName is an embedded type of
                % instanceType: In which case we dont want to replace with
                % categorical...

                try
                    thisValue = instanceTable{1,i};
                
                    if isa(thisValue, 'openminds.abstract.ControlledTerm')
                        options = eval(sprintf('%s.CONTROLLED_INSTANCES', class(thisValue)));
                    
                    elseif isa(thisValue, 'openminds.abstract.Schema')
                        className = openminds.abstract.Schema.getSchemaShortName(class(thisValue)); % Todo: get this in a better way
                        options = [sprintf("None (%s)", className),  obj.getSchemaInstanceLabels(className)];
                    
                    else
                        options = [];
                    end

                    if ~isempty(options)
                        rowValues = cell(numRows, 1);
                        for jRow = 1:numRows
                            thisValue =  instanceTable{jRow,i};
    
                            if isempty(thisValue)
                                thisValue = options(1);
                            else
                                try
                                    % Todo: This need to be improved!!!
                                    thisValue = thisValue.getDisplayLabel;
                                    options(end+1) = thisValue;
                                catch
                                    thisValue = options(1);
                                end
                            end
    
                            rowValues{jRow} = categorical(thisValue, unique(options));
                        end
                        instanceTable.(thisColumnName) = cat(1, rowValues{:});
                    end
                end
            end            
        end
    end

    methods 
        function exist()

        end
    end

    methods (Static)
        function shortSchemaName = getSchemaShortName(fullSchemaName)
        %getSchemaShortName Get short schema name from full schema name
        % 
        %   shortSchemaName = getSchemaShortName(fullSchemaName)
        %
        %   Example:
        %   fullSchemaName = 'openminds.core.research.Subject';
        %   shortSchemaName = om.MetadataSet.getSchemaShortName(fullSchemaName)
        %   shortSchemaName =
        % 
        %     'Subject'

            expression = '(?<=\.)\w*$'; % Get every word after a . at the end of a string
            shortSchemaName = regexp(fullSchemaName, expression, 'match', 'once');
            if isempty(shortSchemaName)
                shortSchemaName = fullSchemaName;
            end
        end
    end

end
