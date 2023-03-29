function tf = existSchema(schemaClassName, schemaCategory, schemaModule)
    schemaClassFilePath = om.strutil.buildClassPath(schemaClassName, schemaCategory, schemaModule);
    tf = isfile(schemaClassFilePath);
end