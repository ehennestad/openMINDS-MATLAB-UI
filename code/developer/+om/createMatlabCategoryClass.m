function createMatlabCategoryClass(schemaName, schemaModule)

    schemaName(1) = upper(schemaName(1));

    schemaCodeStr = sprintf('classdef %s < matlab.mixin.Heterogeneous & handle\n', schemaName);
    schemaCodeStr = [schemaCodeStr, 'end'];
    
    rootPath = om.Preferences.get('MSchemaDirectory');
    folderPath = fullfile(rootPath, '+openminds', ['+', lower(schemaModule)], '+category' );
    if ~isfolder(folderPath); mkdir(folderPath); end
    schemaFilePath = fullfile(folderPath, [schemaName, '.m']);

    om.fileio.writeSchemaClass(schemaFilePath, schemaCodeStr)
     
end