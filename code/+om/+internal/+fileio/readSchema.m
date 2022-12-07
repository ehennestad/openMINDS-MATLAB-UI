function jsonStr = readSchema(schemaName, schemaCategory, schemaModule)
    
    arguments
        schemaName
        schemaCategory
        schemaModule char = 'core'
    end

    folderPath = om.fileio.getSchemaDirectory(schemaModule, schemaCategory);
    
    fileName = sprintf('%s.schema.tpl.json', schemaName);
    
    if isfile(fullfile(folderPath, fileName))
        jsonStr = fileread(fullfile(folderPath, fileName));
    else
        ME = MException('OpenMINDS:SchemaNotFound', ...
            'Requested schema with name "%s" was not found in the %s/%s module', ...
            schemaName, schemaModule, schemaCategory);

        L = dir(fullfile(folderPath, '*.json'));
        schemaNames = {L.name};
        
        % Match expression that ends with ., in the beginning of the text
        schemaNames = regexp(schemaNames, '^\w*(?=.)', 'match');
        schemaNames = cat(1, schemaNames{:});

        CE = MException('OpenMINDS:SchemaNotInList', 'Schema is not part of the list of available schemas: %s', strjoin(schemaNames, ', '));

        ME = addCause(ME, CE);
        throw(ME)
    end
    
end