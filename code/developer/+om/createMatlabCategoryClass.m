function createMatlabCategoryClass(schemaName, schemaModule)

    schemaName(1) = upper(schemaName(1));
    
    rootPath = om.Preferences.get('MSchemaDirectory');
    folderPath = fullfile(rootPath, '+openminds', ['+', lower(schemaModule)], '+category' );
    if ~isfolder(folderPath); mkdir(folderPath); end
    schemaFilePath = fullfile(folderPath, [schemaName, '.m']);
    
    if isfile(schemaFilePath)
        return
    end

    schemaCodeStr = sprintf('classdef %s < matlab.mixin.Heterogeneous & handle\n', schemaName);
    schemaCodeStr = [schemaCodeStr, 'end'];

    om.fileio.writeSchemaClass(schemaFilePath, schemaCodeStr)
end