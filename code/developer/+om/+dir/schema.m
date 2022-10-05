function schemaList = schema(moduleName, schemaName)
%SCHEMA Summary of this function goes here
%   Detailed explanation goes here
    
    initPath = om.fileio.getModuleDirectory(moduleName);
    schemaFolder = fullfile(initPath, 'schemas');
    
    [absPath, dirName] = om.dir.listSubDir(schemaFolder, '', {}, 1);

    if ~isempty(dirName)
        [filePath, ~] = om.dir.listFiles(absPath, '.json');
        % schemaCategory = dirName;
    else
        % Todo...
        [filePath, ~] = om.dir.listFiles(schemaFolder, '.json');
    end

    %[filePath, ~] = om.dir.listFiles(absPath, '.json');
    
    numSchemas = numel(filePath);
    [schemaCategories, schemaNames] = deal( cell(1, numSchemas) );

    for i = 1:numSchemas
        [schemaCategories{i}, schemaNames{i}] = om.strutil.splitSchemaPath(filePath{i});
    end

    schemaList = struct('Category', schemaCategories, 'Name', schemaNames);

    if exist('schemaName', 'var')
        schemaList = schemaList(strcmpi({schemaList.Name}, schemaName));
    end
    
end

function str = camelCase(str)
    str = char(str);
    str(1) = lower(str(1));
end
