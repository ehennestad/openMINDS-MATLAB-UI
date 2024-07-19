function [itemNames, itemData] = uiEditHomogeneousList(metadataInstances, typeURI, metadataCollection)

    % Assumes we are editing a property of a schema... 

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

    title = sprintf( 'Edit %s for %s', typeName, className);


    if isempty(structInstances)
        referenceItem = om.convert.toStruct( feval(class(metadataInstances)), metadataCollection );
        editor = om.internal.window.ArrayEditor(structInstances, 'ItemType', typeName, 'Title', title, 'DefaultItem', referenceItem);
    else
        editor = om.internal.window.ArrayEditor(structInstances, 'ItemType', typeName, 'Title', title);
    end

    [itemNames, itemData] = deal({});
end
