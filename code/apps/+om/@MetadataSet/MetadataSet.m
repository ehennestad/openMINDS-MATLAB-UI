classdef MetadataSet < handle & matlab.mixin.CustomDisplay
    
    properties
        SchemaInstances struct = struct
    end


    methods
        
        function add(obj, schemaInstance)
            
            schemaPathName = class(schemaInstance);
            schemaName = regexp(schemaPathName, '(?<=\.)\w*$', 'match', 'once');
            
            n = numel(schemaInstance);

            if ~isfield( obj.SchemaInstances, schemaName )
                subs = struct('type', {'.', '()'}, 'subs', {schemaName, {1:n}});
            obj.SchemaInstances = subsasgn(obj.SchemaInstances, subs, schemaInstance);
            else
                obj.SchemaInstances.(schemaName)(end+1:end+n) = schemaInstance;
            end
                            

            
            % Todo: Autogenerate internalIdentifier and lookupLabel
            
            
        end

        function remove(obj, schemaInstance)
            
            
        end

        function metaTable = getTable(obj, schemaName)

            if isfield(obj.SchemaInstances, schemaName)
                schemaInstanceList = obj.SchemaInstances.(schemaName);
                metaTable = om.objectArrayToMetaTable(schemaInstanceList);
            else
                metaTable = [];
            end

        end
        
    end

    methods (Access = protected)

        function groups = getPropertyGroups(obj)
            propListing = obj.SchemaInstances;
            groups = matlab.mixin.util.PropertyGroup(propListing);
        end

    end
end