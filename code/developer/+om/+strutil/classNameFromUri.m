function schemaClassName = classNameFromUri(schemaUri)
    
    arguments
        schemaUri char
    end

    uri = matlab.net.URI(schemaUri);
    schemaCategory = uri.Path(2);
    schemaName = uri.Path(3);

    schemaClassName = om.strutil.buildClassName(schemaName, '', schemaCategory);
end