function jsonStr = readInstance(instanceName, schemaName, schemaModule)
    
    arguments
        instanceName
        schemaName
        schemaModule char = 'core'
    end

    folderPath = om.fileio.getInstanceDirectory(schemaModule, schemaName);
    
    fileName = sprintf('%s.jsonld', instanceName);
    
    if isfile(fullfile(folderPath, fileName))
        jsonStr = fileread(fullfile(folderPath, fileName));
    else
        ME = MException('OpenMINDS:InstanceNotFound', ...
            'Requested schema with name "%s" was not found for the schema %s in the %s module', ...
            instanceName, schemaName, schemaModule);

        L = dir(fullfile(folderPath, '*.jsonld'));
        instanceNames = {L.name};
        
        % Match expression that ends with ., in the beginning of the text
        instanceNames = regexp(instanceNames, '^\w*(?=.)', 'match');
        instanceNames = cat(1, instanceNames{:});

        CE = MException('OpenMINDS:SchemaNotInList', 'Schema is not part of the list of available schemas: %s', strjoin(instanceNames, ', '));

        ME = addCause(ME, CE);
        throw(ME)
    end
    
end