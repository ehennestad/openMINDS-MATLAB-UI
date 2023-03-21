function generateSchemas(action, options)
    
    % action
    %   "create" : Create if schema does not exist
    %   "update" : Update schema if required
    %   "reset"  : Delete and recreate schema

    % options
    %   SchemaType : Only supports schema.tpl.json ...

    % Todo: 
    %   - [ ] Create switch block for different actions.
    %   - [ ] I.e should separate generator for schemas and instances.
    
    arguments
        action (1,1) string ...
            {mustBeMember(action, ["create", "update", "reset"])} = "create" 

        options.SchemaType (1,1) string ...
            {mustBeMember(options.SchemaType, "schema.tpl.json")} = "schema.tpl.json" 
    end

    schemaTable = om.internal.dir.listSourceSchemas();
    schemaTable.Properties.RowNames = arrayfun(@(i) num2str(i), 1:size(schemaTable,1), 'UniformOutput', false);
    numSchemas = size(schemaTable, 1);

    warning('off', 'backtrace')

    for i = 1:numSchemas
        try
            switch schemaTable.ModuleName(i)
                case {'SANDS', 'computation', 'core', 'publications', 'controlledTerms'}
                    om.generator.SchemaWriter( schemaTable.Filepath(i), action )
            
            end
        catch ME
            fprintf('Failed to create schema for %s\n', schemaTable.SchemaName(i))
            disp(ME.message)
        end
    end

    warning('on', 'backtrace')

end