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
        metadata container.Map
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
                end
            
            
                % Search through all public properties of the metadata value
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

            evtData = CollectionChangedEventData('INSTANCE_ADDED', metadataInstance);
            obj.notify('CollectionChanged', evtData)
        end

        function remove(obj, metadataName)
            obj.metadata.remove(metadataName);
            obj.graph = rmnode(obj.graph, metadataName);
        end

        function updateMetadata(obj)
            % Update all metadata
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
                if isa(thisValue, 'openminds.abstract.Schema') && ~isa(thisValue, 'openminds.controlledterms.ControlledTerm')
                    className = openminds.abstract.Schema.getSchemaShortName(class(thisValue)); % Todo: get this in a better way
                    % obj.getSchemaInstanceLabels(className)

                    options = [sprintf("None (%s)", className),  obj.getSchemaInstanceLabels(className)];

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
                    instanceTable.(thisColumnName) = cat(1,rowValues{:});
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
