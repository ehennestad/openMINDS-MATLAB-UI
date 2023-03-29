function createMatlabSchemaClass(schemaName, schemaCategory, schemaModule, force)

    arguments 
        schemaName
        schemaCategory
        schemaModule
        force = false
    end

    if om.existSchema(schemaName, schemaCategory, schemaModule) && ~force
        return
    else
        cw = om.ClassWriter(schemaName, schemaCategory, schemaModule);
        cw.update()
    end

end