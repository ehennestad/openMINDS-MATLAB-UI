function [schemaCategory, schemaName] = splitSchemaPath(schemaPathStr)

    schemaPathList = strsplit(schemaPathStr, '/');

    schemaCategory = schemaPathList{end-1};
    schemaName = regexp(schemaPathList{end}, '^\w*(?=.)', 'match', 'once');

end