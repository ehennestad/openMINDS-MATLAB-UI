function folderPath = getSchemaDirectory(moduleName, schemaCategory)

    initPath = om.fileio.getModuleDirectory(moduleName);
    folderPath = fullfile(initPath, 'schemas', schemaCategory);

    if ~isfolder(folderPath)
        error('OpenMINDS:SchemaCategoryNotFound', ...
            'There is no schema category "%s" in the %s module', ...
            schemaCategory, moduleName)
    end

end

