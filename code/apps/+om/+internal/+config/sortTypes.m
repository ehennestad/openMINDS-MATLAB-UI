function sortedTypes = sortTypes(className, typeName, types)   

    preferredTypeOrder = om.internal.config.getPreferredTypeOrder(className, typeName);
    if ~isempty(preferredTypeOrder)
        
        shortNames = cellfun(@(c)openminds.internal.utility.getSchemaName(c), types, 'uni', 1);

        [~, idx] = intersect(preferredTypeOrder, shortNames);
        sortedTypes = types(idx);
    else
        sortedTypes = types;
    end
end