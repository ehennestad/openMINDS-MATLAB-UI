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
        SchemaName string % i.e Person
        MetadataModel string % i.e core
    end

    properties 
        id % Todo: get from instance...
    end

    methods % Constructor

        function obj = Serializer()
            
            obj.SchemaType = "https://openminds.ebrains.eu/core/Subject";
            obj.SchemaName = "Subject";

            obj.id = om.strutil.getuuid(); % Todo: get from instance...

            if isempty(obj.Vocab)
                obj.Vocab = obj.DEFAULT_VOCAB;
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

            % Get names of linked properties from Schema.

            % Get names of embedded properties from Schema.

            % Add public properties. For linked types, add links...
            
            jsonStr = om.json.encode(S);
        end

    end

    methods (Access = private) % Note: Make protected if subclasses are created
        
        function addLinkedType(obj)
            
        end

        function addEmbeddedType(obj)
            
        end

    end

end