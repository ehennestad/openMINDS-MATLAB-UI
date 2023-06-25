classdef Serializer < handle

%     TODO:
%     - [x] Create a Serialiser class
%     - [ ] Adapt Serializer class to serve as mixin for the instance class
%     - [ ] Add handling for public properties, and add links for all linked types.
%     - [ ] Handle embedded types.
%     - [ ] Consider whether it is enough to have a mixin, or we should use the strategy pattern and have Serializer as a property of Instance in order to flexibly change between different serialization techniques
%     - [ ] How to resolve whether something is a linked or embedded type.
%           - Save on the schema class...



    properties (Constant)
        DEFAULT_VOCAB = "https://openminds.ebrains.eu"
        LOCAL_IRI = "http://localhost"
    end

    properties
        Vocab
        SchemaType string % i.e https://openminds.ebrains.eu/core/Person
        MetadataModel string % i.e core
    end
    
    properties (Dependent)
        SchemaName string % i.e Person
    end

    properties 
        Instance % openminds.abstract.Schema
        id % Todo: get from instance...
    end

    methods % Constructor

        function obj = Serializer( instanceObject )
            
            if isa( instanceObject, 'openminds.abstract.LinkedCategory' )
                instanceObject = instanceObject.Instance;
                warning('Please report if you see this warning!')
            end

            if numel(instanceObject) > 1
                error('Serialization of non-scalar objects is not supported yet')
            end

            if ~isa(instanceObject, 'openminds.abstract.Schema')
                error('Serializer input must be an openMINDS instance. The provided instance is of type "%s"', class(instanceObject))
            end

            obj.Instance = instanceObject;

            obj.SchemaType = instanceObject.X_TYPE;

            obj.id = obj.Instance.id;

            if isempty(obj.Vocab)
                obj.Vocab = obj.DEFAULT_VOCAB;
            end

            if ~nargout
                obj.serialize()
                clear obj
            end

        end
        
    end

    methods 
        function name = get.SchemaName(obj)
            
            if isempty(obj.SchemaType)
                name = '';
            else
                schemaTypeSplit = strsplit(obj.SchemaType, '/');
                name = schemaTypeSplit{end};
            end
        end
    end

    methods 

        function jsonStr = serialize(obj)

            S = struct;

            S.at_context = struct();
            S.at_context.at_vocab = sprintf("%s/vocab", obj.Vocab);

            S.at_type = {obj.SchemaType};
            S.at_id = obj.getIdentifier(obj.Instance.id);
            
            % Get public properties
            propertyNames = properties(obj.Instance);

            % Get names of linked & embedded properties from instance.
            linkedPropertyStruct = obj.Instance.LINKED_PROPERTIES;
            embeddedPropertyStruct = obj.Instance.EMBEDDED_PROPERTIES;

            % Serialize each of the properties. For linked types, add links...
            for i = 1:numel(propertyNames)
                
                iPropertyName = propertyNames{i};
                iPropertyValue = obj.Instance.(iPropertyName);

                if isempty(iPropertyValue); continue; end
                if isstring(iPropertyValue) && iPropertyValue==""; continue; end

                if any(strcmp(fieldnames(linkedPropertyStruct), iPropertyName))
                    S.(iPropertyName) = obj.serializeLinkedProperty(iPropertyValue);

                elseif any(strcmp(fieldnames(embeddedPropertyStruct), iPropertyName))
                    %S.(iPropertyName) = obj.serializeEmbeddedProperty(iPropertyValue);
                    warning('Serialization of embedded properties ("%s") is not implemented yet', iPropertyName)
                else
                    S.(iPropertyName) = iPropertyValue;
                end
            end

            % Todo: 
            %   [ ] Test cell arrays where a property can be linked from
            %       multiple different schema instances.
            %
            %   [ ] Test arrays
            %   [ ] Test scalars

            % Todo: Serialize embedded instance and add it to the embedded
            % property key

            % Expand the property names with the vobab url/iri.
            jsonStr = om.json.encode(S);

            for i = 1:numel(propertyNames)
                iPropertyNameStr = sprintf('"%s"',  propertyNames{i});
                iPropertyNameVocabStr = sprintf('"%s/vocab/%s"', obj.DEFAULT_VOCAB, propertyNames{i});
                
                jsonStr = strrep(jsonStr, [iPropertyNameStr, ':'], [iPropertyNameVocabStr, ':'] );
            end
        end

        function s = serializeLinkedProperty(obj, linkedPropertyValues)
            s = struct('at_id', {});

            for i = 1:numel(linkedPropertyValues)
                iValue = linkedPropertyValues(i);
                s(i).at_id = obj.getIdentifier(iValue.id);
            end

        end

    end

    methods (Access = private) % Note: Make protected if subclasses are created
        
        function S = addLinkedType(obj, S, propName, propValue)
            
        end

        function S = addEmbeddedType(obj, S, propName, propValue)
            
        end

    end

    methods (Static)

        function id = getIdentifier(instanceID)
            id = sprintf("%s/%s", openminds.Serializer.LOCAL_IRI, instanceID);
        end

    end

end