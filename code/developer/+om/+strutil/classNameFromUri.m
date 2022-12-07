function schemaClassName = classNameFromUri(schemaUri)
    
    arguments
        schemaUri char
    end

    persistent schemaList
    if isempty(schemaList)
        schemaList = om.internal.dir.listSourceSchemas();
    end

    uri = matlab.net.URI(schemaUri);
    schemaModule = uri.Path(2);
    schemaName = uri.Path(3);

    isMatch = strcmpi(schemaList.SchemaName, schemaName) ...
                & strcmpi(schemaList.ModuleName, schemaModule);
    if ~any(isMatch)
        schemaClassName = '';
        warning('OPENMINDS:SchemaNotFound', 'Schema %s.%s was not found', schemaModule, schemaName)
    else
        t = schemaList(isMatch, :);
        schemaClassName = om.strutil.buildClassName(t.SchemaName, t.SubModuleName, t.ModuleName);
    end

    %     try
%         s = om.dir.schema(schemaModule, schemaName);
%     catch
%         warning('The schema "%s" is not available', schemaUri)
%         schemaClassName = ''; return
%     end
%     
%     if ~isempty(s.Category)
%         schemaCategory = s.Category;
%     else
%         schemaCategory = '';
%     end
% 
%     if strcmp(schemaCategory, 'schemas')
%         schemaCategory = '';
%     end
%     
%     schemaClassName = om.strutil.buildClassName(schemaName, schemaCategory, schemaModule);
end