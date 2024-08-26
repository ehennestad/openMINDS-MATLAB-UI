function instance = getControlledInstance(instanceId)

    arguments
        instanceId (1,1) string
    end

    if ~startsWith(instanceId, "https://openminds.ebrains.eu/instances/")
        error('ID needs to start with "https://openminds.ebrains.eu/instances/"')
    end

    [~, schemaType, ] = fileparts(fileparts(instanceId));
    instance = feval( om.enum.Types(schemaType).ClassName, instanceId );
end