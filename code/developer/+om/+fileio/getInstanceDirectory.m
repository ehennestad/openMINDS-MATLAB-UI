function folderPath = getInstanceDirectory(moduleName, instanceCategory)

    initPath = om.fileio.getModuleDirectory(moduleName);
    folderPath = fullfile(initPath, 'instances', instanceCategory);

    if ~isfolder(folderPath)
        error('OpenMINDS:InstanceCategoryNotFound', ...
            'There is no instance category "%s" in the %s module', ...
            instanceCategory, moduleName)
    end

end

