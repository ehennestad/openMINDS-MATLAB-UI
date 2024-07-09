function structInstance = toStruct(openMindsInstance, metadataCollection)

    
    if numel( openMindsInstance ) > 1
        structInstance = cell(1, numel(openMindsInstance) );
        for i = 1:numel(structInstance)
            structInstance{i} = om.convert.toStruct( openMindsInstance(i), metadataCollection );
        end
        structInstance = [structInstance{:}];
        return
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
            if ismissing(iValue)
                iValue = '';
            end
            SNew.(iPropName) = char(iValue);
        elseif isnumeric(iValue)
            SNew.(iPropName) = double(iValue);
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
            %SNew.(iPropName) = valueOptions{1};
            %SNew.(iPropName_) = valueOptions;
            SNew.(iPropName) = categorical(valueOptions(1), valueOptions);

            if metaSchema.isPropertyValueScalar(iPropName)
                SNew.([iPropName,'_']) = 'om.internal.control.DropDownPlus';
            else
                SNew.([iPropName,'_']) = 'om.internal.control.ListControl';
            end
        
        elseif isa(iValue, 'openminds.internal.abstract.LinkedCategory')

            SNew.(iPropName) = '';
        else
            warning('Values of type %s is not dealt with', class(iValue))
        end
    end
    structInstance = SNew;
end