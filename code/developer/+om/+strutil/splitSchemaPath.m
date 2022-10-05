function [schemaCategory, schemaName] = splitSchemaPath(schemaPathStr)

    schemaPathList = strsplit(schemaPathStr, '/');

    if numel(schemaPathList) > 1
        schemaCategory = schemaPathList{end-1};
    else
        schemaCategory = '';
    end
    schemaName = regexp(schemaPathList{end}, '^\w*(?=.)', 'match', 'once');

end