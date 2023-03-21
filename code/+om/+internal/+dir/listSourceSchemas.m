function schemaInfo = listSourceSchemas(schemaModule, options)
%listSourceSchemas List information about all available schemas.   
%   
%   schemaInfo = listSourceSchemas() returns a table with information
%   about all the available schemas.

    arguments
        schemaModule = {}
        options.SchemaType = 'schema.tpl.json';
        options.SchemaFileExtension = '.json';
    end
    
    %options.SchemaType = 'schema.tpl.json';
    
    % - Get path constant
    openMindsFolderPath = om.Constants.getRootPath();
    schemaFolderPath = fullfile( openMindsFolderPath, 'schemas', ...
                                 'source', options.SchemaType);
    
    filePaths = listSchemaFiles(schemaFolderPath, schemaModule, options.SchemaFileExtension);

    S = collectInfoInStructArray(schemaFolderPath, filePaths);

    schemaInfo = convertStructToTable(S);
end

function [filePaths] = listSchemaFiles(schemaFolderPath, schemaModule, fileExtension)
%listSchemaFiles List schema files given a root directory

    import om.internal.dir.listSubDir
    import om.internal.dir.listFiles 

    if nargin < 3 || isempty(fileExtension)
        fileExtension = '.json';
    end

    % - Look through subfolders for all json files of specified modules
    [absPath, dirName] = listSubDir(schemaFolderPath, '', {}, 0);
    
    if ~isempty(schemaModule) % Filter by given module(s), if any
        [~, keepIdx] = intersect(dirName, schemaModule);
        absPath = absPath(keepIdx);
    end

    [absPath, ~] = listSubDir(absPath, '', {}, 2);
    [filePaths, ~] = listFiles(absPath, fileExtension);
end

function S = collectInfoInStructArray(schemaFolderPath, filePaths)

    FILE_EXT = '.schema.tpl';
    
    % - Get relevant parts of folder hierarchy for extracting information
    folderNames = replace(filePaths, schemaFolderPath, '');
    [folderNames, fileNames] = fileparts(folderNames);

    % - Create struct array with information about all schemas
    schemaNames = replace(fileNames, FILE_EXT, '');
    S = struct('SchemaName', schemaNames);

    for i = 1:numel(S)

        thisFolderSplit = strsplit(folderNames{i}, filesep);
        if isempty(thisFolderSplit{1})
            thisFolderSplit(1) = [];
        end

        S(i).ModuleName = thisFolderSplit{1};
        S(i).ModuleVersion = thisFolderSplit{2};
        if numel(thisFolderSplit) == 3
            S(i).SubModuleName = matlab.lang.makeValidName(thisFolderSplit{3});
        else
            S(i).SubModuleName = '';
        end
        S(i).Filepath = filePaths{i};
    end
end

function schemaInfo = convertStructToTable(S)
%convertStructToTable Convert struct to table and format columns as strings
    
    % - Convert struct array to table
    schemaInfo = struct2table(S);
    
    % - Convert all columns to string columns
    for i = 1:size(schemaInfo, 2)
        varName = schemaInfo.Properties.VariableNames{i};
        schemaInfo.(varName) = string(schemaInfo.(varName));
    end
end