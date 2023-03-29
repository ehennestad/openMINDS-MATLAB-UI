function schemaList = instance(moduleName, schemaName)
%SCHEMA Summary of this function goes here
%   Detailed explanation goes here
    
    initPath = om.fileio.getModuleDirectory(moduleName);
    schemaFolder = fullfile(initPath, 'instances', schemaName);

    % Find .m files in schema schemaFolder
    
    [filePath, ~] = om.dir.listFiles(schemaFolder, '.jsonld');

    numSchemas = numel(filePath);
    [schemaCategories, schemaNames] = deal( cell(1, numSchemas) );

    for i = 1:numSchemas
        [schemaCategories{i}, schemaNames{i}] = om.strutil.splitSchemaPath(filePath{i});
    end

    schemaList = struct('Category', schemaCategories, 'Name', schemaNames);

end