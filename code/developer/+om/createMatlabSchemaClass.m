function createMatlabSchemaClass(schemaName, schemaCategory, schemaModule)
    cw = om.ClassWriter(schemaName, schemaCategory, schemaModule);
    cw.update()
end