function schemaClassName = classNameFromUri(schemaUri)
    
    arguments
        schemaUri char
    end

    uri = matlab.net.URI(schemaUri);
    schemaModule = uri.Path(2);
    schemaName = uri.Path(3);

    s = om.dir.schema(schemaModule, schemaName);
    if ~isempty(s.Category)
        schemaCategory = s.Category;
    else
        schemaCategory = '';
    end

    if strcmp(schemaCategory, 'schemas')
        schemaCategory = '';
    end
    
    schemaClassName = om.strutil.buildClassName(schemaName, schemaCategory, schemaModule);
end