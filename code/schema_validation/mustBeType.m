function mustBeType(value, allowedTypes)

    types = cellfun(@(c) class(c), value, 'UniformOutput', false);

    isValidType = iscell(value) && all(ismember(types, allowedTypes));
    validTypesStr = getValidTypesAsFormattedString(allowedTypes);

    assert(isValidType, 'Value must be one of the following types:' + validTypesStr)
end


function str = getValidTypesAsFormattedString(allowedTypes)
    str = sprintf("\n" + strjoin( allowedTypes, ",\n") + "\n");
end