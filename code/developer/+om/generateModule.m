function generateModule(moduleName, force)

    arguments
        moduleName
        force = false
    end

    schemaList = om.dir.schema(moduleName);

    numSchemas = numel(schemaList);

    for i = 1:numSchemas

        if om.existSchema(schemaList(i).Name, schemaList(i).Category, moduleName) && ~force
            continue
        else
            try
                om.ClassWriter(schemaList(i).Name, schemaList(i).Category, moduleName);
            catch ME
                fprintf('failed for %s\n', schemaList(i).Name)
                disp(ME.message)
            end
        end
    end

end