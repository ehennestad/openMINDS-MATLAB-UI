function structInstance = toStruct(openMindsInstance, metadataCollection)

    
    if numel( openMindsInstance ) > 1
        structInstance = cell(1, numel(openMindsInstance) );
        for i = 1:numel(structInstance)
            structInstance{i} = om.convert.toStruct( openMindsInstance(i), metadataCollection );
        end
        structInstance = [structInstance{:}];
        return
    end

    if isempty(openMindsInstance) && isa(openMindsInstance, 'openminds.abstract.Schema')
        openMindsInstance = feval(class(openMindsInstance));
    end

    % TODO: Consider to make this more internal...
    if isa(openMindsInstance, 'openminds.internal.abstract.LinkedCategory')
        if isempty(openMindsInstance)
            structInstance = struct.empty; return
        else
            openMindsInstance = openMindsInstance.Instance;
        end
    end

    [SOrig, SNew] = deal( openMindsInstance.toStruct() );

    
    metaSchema = openminds.internal.SchemaInspector( openMindsInstance );

    % Fill out options for each property
    propNames = fieldnames(SOrig);

    for i = 1:numel(propNames)
        
        iPropName = propNames{i};
        iPropName_ = [iPropName, '_'];
        iValue = SNew.(iPropName);

        if isenum(iValue)
            [~, m] = enumeration( iValue );
            SNew.(iPropName) = m{1};
            SNew.(iPropName_) = m;

        elseif isstring(iValue)
            if ismissing(iValue); iValue = ''; end
            SNew.(iPropName) = char(iValue);

        elseif isnumeric(iValue)
            SNew.(iPropName) = double(iValue);

        elseif isdatetime(iValue)
            % pass

        elseif isa(iValue, 'openminds.abstract.ControlledTerm')
            m = eval( sprintf('%s.CONTROLLED_INSTANCES', class(iValue)));
            SNew.(iPropName) = categorical(m(1), m);

        elseif isa(iValue, 'openminds.abstract.Schema')

            schemaLabels = metadataCollection.getSchemaInstanceLabels(class(iValue));
            schemaShortName = openminds.MetadataCollection.getSchemaShortName(class(iValue));

            if isempty(schemaLabels)
                valueOptions = {sprintf('No %s available', schemaShortName)};
            else
                valueOptions = [sprintf('Select a %s', schemaShortName), schemaLabels];
            end

            SNew.(iPropName) = categorical(valueOptions(1), valueOptions);

            if metaSchema.isPropertyValueScalar(iPropName)
                SNew.(iPropName_) = 'om.internal.control.DropDownPlus';
                SNew.(iPropName_) = @(h, varargin) om.internal.control.DropDownPlus(h, 'EditItemsFcn', @(varargin) om.uiCreateNewInstance(class(iValue), openMindsInstance.X_TYPE+"/"+iPropName ));
            else
                SNew.(iPropName_) = 'om.internal.control.ListControl';
            end
        
        elseif isa(iValue, 'openminds.internal.abstract.LinkedCategory') % One of / any of
            
            if metaSchema.isPropertyValueScalar(iPropName)
                SNew.(iPropName) = '';
                SNew.(iPropName_) = 'om.internal.control.DropDownPlus';
                %SNew.(iPropName_) = @(h, varargin) om.internal.control.DropDownPlus(h, 'EditItemsFcn', @(varargin) om.uiCreateNewInstance(class(iValue), openMindsInstance.X_TYPE+"/"+iPropName ));
            else
                SNew.(iPropName) = string(iValue);
                SNew.(iPropName_) = @(h, varargin) om.internal.control.ListControl(h, 'EditItemsFcn', @(varargin) om.uiEditHeterogeneousList(iValue, openMindsInstance.X_TYPE+"/"+iPropName ));
            end
        
        else
            warning('Values of type %s is not dealt with', class(iValue))
        end
    end
    structInstance = SNew;
end