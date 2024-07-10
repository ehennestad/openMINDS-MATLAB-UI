function [itemNames, itemData] = uiEditHeterogeneousList(metadataInstances, typeURI, metadataCollection)

    
    % Assumes we are editing a property of a schema... Which should always
    % be the case for heterogeneous arrays...
    
    typePathSplit = strsplit(typeURI, '/');

    typeName = typePathSplit{end};
    className = typePathSplit{end-1};

    if nargin < 3
        metadataCollection = openminds.MetadataCollection();
    end

    numInstances = numel( metadataInstances );
    if numInstances >= 1
        structInstances = om.convert.toStruct( metadataInstances, metadataCollection );
    else
        structInstances = struct.empty;
    end
    
    % Also: Get reference types...
    allTypes = eval( sprintf("%s.ALLOWED_TYPES", class(metadataInstances)) );
    referenceItems = struct('Type', {}, 'Data', {});
    for i = 1:numel(allTypes)
        referenceItems(i).Type = allTypes{i};
        referenceItems(i).Data = om.convert.toStruct( feval(allTypes{i}), metadataCollection );
    end
    
    referenceItems = structeditor.TypedStructArray({}, {referenceItems.Data}, allTypes);

    title = sprintf( 'Edit %s for %s', typeName, className);
    editor = om.internal.window.HeterogeneousArrayEditor(structInstances, 'ItemType', typeName, 'Title', title, 'DefaultItem', referenceItems);

    [itemNames, itemData] = deal({});

end