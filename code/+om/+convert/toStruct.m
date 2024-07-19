function structInstance = toStruct(openMindsInstance, metadataCollection)
    
    if isempty( openMindsInstance ) 
        structInstance = struct.empty; return

    elseif numel( openMindsInstance ) > 1 
        structInstance = cell(1, numel(openMindsInstance) );
        for i = 1:numel(structInstance)
            structInstance{i} = om.convert.toStruct( openMindsInstance(i), metadataCollection );
        end
        %structInstance = [structInstance{:}];
        return
    end

    % NB: Special case. Todo: Consider to make this more internal.
    if isa(openMindsInstance, 'openminds.internal.abstract.LinkedCategory')
        openMindsInstance = openMindsInstance.Instance;
    end

    try
        structInstance = openMindsInstance.toStruct();
    catch
        keyboard
    end
    openMindsType = class(openMindsInstance);

    % Order fields according to settings/preferences
    propertyOrder = om.internal.config.getPreferredPropertyOrder( openMindsType );
    structInstance = orderfields(structInstance, propertyOrder);
    
    metaSchema = openminds.internal.SchemaInspector( openMindsInstance );

    % Fill out options for each property
    propNames = fieldnames(structInstance);

    for i = 1:numel(propNames)
        
        iPropName = propNames{i};
        iValue = structInstance.(iPropName);
        iConfig = [];
        customFcn = [];

        if isstring(iValue)
            if ismissing(iValue); iValue = ''; end
            iValue = char(iValue);

        elseif isnumeric(iValue)
            iValue = double(iValue);

        elseif isdatetime(iValue)
            % pass

        elseif isenum(iValue) % Deprecated?
            [~, names] = enumeration( iValue );
            iValue = categorical(names(1), names);

        elseif isa(iValue, 'openminds.abstract.ControlledTerm')
            names = eval( sprintf('%s.CONTROLLED_INSTANCES', class(iValue)));
            iValue = categorical(names(1), names);

        elseif isa(iValue, 'openminds.abstract.Schema')
            if metaSchema.isPropertyValueScalar(iPropName)
                customFcn = @getConfigForScalarValue;
            else
                customFcn = @getConfigForNonScalarValue;
            end

        elseif isa(iValue, 'openminds.internal.abstract.LinkedCategory') % oneOf/anyOf
            if metaSchema.isPropertyValueScalar(iPropName)
                customFcn = @getConfigForHeterogeneousScalarValue;
            else
                customFcn = @getConfigForHeterogeneousNonScalarValue;
            end

        else
            warning('Values of type %s is not dealt with', class(iValue))
        end

        if ~isempty(customFcn)
            [iValue, iConfig] = customFcn(iPropName, iValue, openMindsInstance, metadataCollection);
        end

        structInstance.(iPropName) = iValue;
        if ~isempty(iConfig)
            iPropName_ = [iPropName, '_'];
            structInstance.(iPropName_) = iConfig;
        end
    end

    structInstance.id = openMindsInstance.id;
    structInstance.id_ = 'hidden';    
end

% Local functions

function [value, config] = getConfigForScalarValue(name, value, openMindsInstance, metadataCollection)

    typeShortName = openminds.internal.utility.getSchemaShortName(class(value));
    existingInstances = metadataCollection.list( typeShortName );

    if ~isempty(existingInstances)
        schemaLabels = arrayfun(@(x) string(x), existingInstances);
        items = cat(2, sprintf('Select a %s', typeShortName), schemaLabels);
    else
        items = {sprintf('No %s available', typeShortName)};
    end
    
    emptyInstance = feval(sprintf('%s.empty', class(value)));

    if isempty(value)
        value = emptyInstance; 
    end

    itemsData = [{emptyInstance}, num2cell( existingInstances ) ];

    propertyTypeName = openMindsInstance.X_TYPE + "/" + name;

    editItemsFcn = @(value, varargin) ...
        om.uiCreateNewInstance(value, propertyTypeName, metadataCollection );

    config = @(h, varargin) om.internal.control.DropDownPlus(h, ...
        'Items', items, ...
        'ItemsData', itemsData, ...
        'EditItemsFcn', editItemsFcn);

end


function [value, config] = getConfigForNonScalarValue(name, value, openMindsInstance, metadataCollection)

    propertyTypeName = openMindsInstance.X_TYPE + "/" + name;

    editItemsFcn = @(value, varargin) ...
        om.uiEditHeterogeneousList(value, propertyTypeName, metadataCollection );
    
    items = arrayfun(@(x) string(x), value);
    if isempty(value)
        value = {value};
    else
        value = num2cell( value );
    end

    config = @(h, varargin) om.internal.control.ListControl(h, ...
        'Items', items, ...
        'ItemsData', value, ...
        'EditItemsFcn', editItemsFcn);
end

function [value, config] = getConfigForHeterogeneousScalarValue(name, value, openMindsInstance, metadataCollection)
    value = ''; config = []; % Not implemented yet
end

function [value, configFcn] = getConfigForHeterogeneousNonScalarValue(name, value, openMindsInstance, metadataCollection)
    
    propertyTypeName = openMindsInstance.X_TYPE + "/" + name;

    editItemsFcn = @(value, varargin) ...
        om.uiEditHeterogeneousList(value, propertyTypeName, metadataCollection );
    
    items = arrayfun(@(x) string(x), value);
    if isempty(value)
        value = {value};
    else
        value = num2cell( value );
    end

    configFcn = @(h, varargin) om.internal.control.ListControl(h, ...
        'Items', items, ...
        'ItemsData', value, ...
        'EditItemsFcn', editItemsFcn);
end
