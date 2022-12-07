function generateSchemas(action, options)
    
    % action
    %   "create" : Create if schema does not exist
    %   "update" : Update schema if required
    %   "reset"  : Delete and recreate schema

    % options
    %   SchemaType : Only supports schema.tpl.json ...

    % Todo: Create switch block for different actions.

    arguments
        action (1,1) string ...
            {mustBeMember(action, ["create", "update", "reset"])} = "create" 

        options.SchemaType (1,1) string ...
            {mustBeMember(options.SchemaType, "schema.tpl.json")} = "schema.tpl.json" 
    end

    schemaTable = om.internal.dir.listSourceSchemas();
    numSchemas = size(schemaTable, 1);

    warning('off', 'backtrace')

    for i = 1:numSchemas
        try
            switch schemaTable.ModuleName(i)
                case {'SANDS', 'computation', 'core', 'publications'}
                    om.generator.SchemaWriter( schemaTable.Filepath(i) )
                case 'controlledTerms'
                    %om.generateControlledTermSchemas()
            end
        catch ME
            fprintf('Failed to create schema for %s\n', schemaTable.SchemaName(i))
            disp(ME.message)
        end
    end

    warning('on', 'backtrace')

end