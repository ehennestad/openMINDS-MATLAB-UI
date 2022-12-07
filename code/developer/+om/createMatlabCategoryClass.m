function createMatlabCategoryClass(schemaName, ~)

    schemaName(1) = upper(schemaName(1));
    
    rootPath = om.getPreferences('MSchemaDirectory');
    folderPath = fullfile(rootPath, '+openminds', '+category' );
    if ~isfolder(folderPath); mkdir(folderPath); end
    schemaFilePath = fullfile(folderPath, [schemaName, '.m']);
    
    if isfile(schemaFilePath)
        return
    end

    schemaCodeStr = sprintf('classdef %s < handle\n', schemaName);
    commentStr = sprintf('%% This is an "umbrella" for schemas that belong to the same category.\n');
    schemaCodeStr = [schemaCodeStr, commentStr];
    schemaCodeStr = [schemaCodeStr, 'end'];

    om.fileio.writeSchemaClass(schemaFilePath, schemaCodeStr)
end