function generateModule(moduleName)


    schemaList = om.dir.schema(moduleName);

    numSchemas = numel(schemaList);

    for i = 1:numSchemas
        om.ClassWriter(schemaList(i).Name, schemaList(i).Category, moduleName);
    end

end