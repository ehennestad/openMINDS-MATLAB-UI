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
            
            obj.Instance = instanceObject;

            obj.SchemaType = instanceObject.X_TYPE;

            obj.id = om.strutil.getuuid(); % Todo: get from instance...

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

            S.at_type = obj.SchemaType;
            S.at_id = sprintf("%s/%s/%s", obj.LOCAL_IRI, obj.SchemaName, obj.id);
            

            % Get public properties
            propertyNames = properties(obj.Instance);
            
            % Serialize each of the properties. For linked types, add links...


            % Get names of linked properties from instance.
            linkedPropertyStruct = obj.Instance.LINKED_PROPERTIES;

            % Serialize with IDs for linked instances.

            % Todo: 
            %   [ ] Handle cell arrays where a property can be linked from
            %       multiple different schema instances.
            %
            %   [ ] Handle arrays
            %   [ ] Handle scalars
            %   [ ] Skip property with empty values


            % Get names of embedded properties from instance.
            embeddedPropertyStruct = obj.Instance.EMBEDDED_PROPERTIES;

            % Todo: Serialize embedded instance and add it to the embedded
            % property key

            jsonStr = om.json.encode(S);
        end

    end

    methods (Access = private) % Note: Make protected if subclasses are created
        
        function S = addLinkedType(obj, S, propName, propValue)
            
        end

        function S = addEmbeddedType(obj, S, propName, propValue)
            
        end

    end

end