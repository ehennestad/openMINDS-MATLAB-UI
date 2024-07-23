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

        if iscell(structInstances)
            structInstances = [structInstances{:}];
        end

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
        
        if ~iscell(data)
            data = num2cell(data);
        end

        instances = {};

        for i = 1:numel(data)
            if isHeterogeneous
                openmindsType = referenceItems.getStructType(data{i});
            else
                openmindsType = class(metadataInstances);
            end

            iData = data{i};
            if isfield(iData, 'id') && ~isempty(iData.id)
                % retrieve existing instance.
                
                if isempty(metadataInstances)
                    iInstance = feval( openmindsType, 'id', iData.id );
                else
                    if isa(metadataInstances, 'openminds.abstract.Schema')
                        isInstance = strcmp( {metadataInstances.id}, iData.id );
                        iInstance = metadataInstances(isInstance);
                    elseif isa(metadataInstances, 'openminds.internal.abstract.LinkedCategory')
                        instanceIds = arrayfun(@(x) x.Instance.id, metadataInstances, 'uni', false);
                        isInstance = strcmp( instanceIds, iData.id );
                        iInstance = metadataInstances(isInstance).Instance; % Todo: Fix for .Instance
                    else
                        error('Unkown class for metadata instance')
                    end
                end
                if isempty(iInstance)
                    iInstance = metadataInstances(isInstance);
                end
            else
                iInstance = feval( openmindsType );
            end
            instances{i} = om.convert.fromStruct(iInstance, iData, metadataCollection); %#ok<AGROW>

            if ~metadataCollection.contains( instances{i} )
                metadataCollection.add( instances{i} )
            end
        end

        % Convert to openminds instances to get labels...    
        itemNames = cellfun(@(c) char(c), instances, 'UniformOutput', false);

        if isHeterogeneous
            mixedTypeName = class(metadataInstances);
            itemData = num2cell( feval(mixedTypeName, instances) );
        else
            itemData = instances;
        end
    end

    delete(editor)
end
