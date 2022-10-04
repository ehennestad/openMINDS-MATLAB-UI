function schemaList = schema(moduleName)
%SCHEMA Summary of this function goes here
%   Detailed explanation goes here
    
    initPath = om.fileio.getModuleDirectory(moduleName);
    schemaFolder = fullfile(initPath, 'schemas');
    
    [absPath, dirName] = om.dir.listSubDir(schemaFolder, '', {}, 1);

    if ~isempty(dirName)
        % schemaCategory = dirName;
    else
        % Todo...
    end

    [filePath, ~] = om.dir.listFiles(absPath, '.json');
    
    numSchemas = numel(filePath);
    [schemaCategories, schemaNames] = deal( cell(1, numSchemas) );

    for i = 1:numSchemas
        [schemaCategories{i}, schemaNames{i}] = om.strutil.splitSchemaPath(filePath{i});
    end

    schemaList = struct('Category', schemaCategories, 'Name', schemaNames);
    
end
