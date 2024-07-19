function [itemNames, itemData] = uiEditHeterogeneousList(metadataInstances, typeURI, metadataCollection)

    % Todo: order of outputs should match uiCreateNewInstance...
    
    % Assumes we are editing a property of a schema... Which should always
    % be the case for heterogeneous arrays...
    
    typePathSplit = strsplit(typeURI, '/');

    typeName = typePathSplit{end};
    className = typePathSplit{end-1};

    if nargin < 3
        metadataCollection = openminds.MetadataCollection();
    end
        
    if iscell(metadataInstances); metadataInstances = [metadataInstances{:}]; end

    isHeterogeneous = isa(metadataInstances, 'openminds.internal.abstract.LinkedCategory');

    numInstances = numel( metadataInstances );
    if numInstances >= 1
        structInstances = om.convert.toStruct( metadataInstances, metadataCollection );
    else
        structInstances = struct.empty;
    end

    title = sprintf( 'Edit %s for %s', typeName, className);

    if isHeterogeneous
        if ~isa(structInstances, 'cell')
            structInstances = num2cell(structInstances);
        end
    
        % Also: Get reference types...
        allTypes = eval( sprintf("%s.ALLOWED_TYPES", class(metadataInstances)) );
        allTypes = om.internal.config.sortTypes(className, typeName, allTypes);

        referenceItems = struct('Type', {}, 'Data', {});
        for i = 1:numel(allTypes)
            referenceItems(i).Type = allTypes{i};
            referenceItems(i).Data = om.convert.toStruct( feval(allTypes{i}), metadataCollection );
        end
    
        referenceItems = structeditor.TypedStructArray({}, {referenceItems.Data}, allTypes);
    
        editor = om.internal.window.HeterogeneousArrayEditor(structInstances, 'ItemType', typeName, 'Title', title, 'DefaultItem', referenceItems);
    else
        typeName = class(metadataInstances);
        typeName = openminds.internal.utility.getSchemaShortName(typeName);

        if isempty(structInstances)
            referenceItem = om.convert.toStruct( feval(class(metadataInstances)), metadataCollection );
            editor = om.internal.window.ArrayEditor(structInstances, 'ItemType', typeName, 'Title', title, 'DefaultItem', referenceItem);
        else
            editor = om.internal.window.ArrayEditor(structInstances, 'ItemType', typeName, 'Title', title);
        end
    end

    uim.utility.centerFigure(editor.UIFigure)
    uiwait(editor, true)
    
    if ~isvalid(editor) || editor.FinishState ~= "Finished"
        [itemNames, itemData] = deal([]);
    else
        % Heterogeneous...
        data = editor.Data;

        instances = {};

        for i = 1:numel(data)
            openmindsType = referenceItems.getStructType(data{i});
            iData = data{i};
            iInstance = feval( openmindsType );
            
            instances{i} = om.convert.fromStruct(iInstance, iData, metadataCollection); %#ok<AGROW>
        end

        % Convert to openminds instances to get labels...    
        itemNames = cellfun(@(c) char(c), instances, 'UniformOutput', false);
        mixedTypeName = class(metadataInstances);
        itemData = num2cell( feval(mixedTypeName, instances) );
    end

    delete(editor)
end
