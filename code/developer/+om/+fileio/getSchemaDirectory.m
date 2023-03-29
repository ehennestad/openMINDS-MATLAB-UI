function folderPath = getSchemaDirectory(moduleName, schemaCategory)

    initPath = om.fileio.getModuleDirectory(moduleName);
    if strcmp(schemaCategory, 'schemas')
        folderPath = fullfile(initPath, 'schemas');
    else
        folderPath = fullfile(initPath, 'schemas', schemaCategory);
    end

    if ~isfolder(folderPath)
        error('OpenMINDS:SchemaCategoryNotFound', ...
            'There is no schema category "%s" in the %s module', ...
            schemaCategory, moduleName)
    end

end