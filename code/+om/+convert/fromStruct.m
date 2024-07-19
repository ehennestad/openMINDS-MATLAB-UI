function instance = fromStruct(instance, data, metadataCollection)

    propNames = properties(instance);

    for i = 1:numel(propNames)
        iPropName = propNames{i};
        iValue = instance.(iPropName);

        if isenum(iValue)
            enumFcn = str2func( class(iValue) );
            instance.(iPropName) = enumFcn(data.(iPropName));
        
        elseif isstring(iValue)
            instance.(iPropName) = char(data.(iPropName));
        elseif isnumeric(iValue)
            instance.(iPropName) = cast(data.(iPropName), class(instance.(iPropName)));
        elseif isa(iValue, 'openminds.abstract.ControlledTerm')
            instance.(iPropName) = char(data.(iPropName));
        elseif isa(iValue, 'openminds.abstract.Schema')
            if isSchemaInstanceUnavailable(data.(iPropName)) % local function
                %instance.(iPropName) = data.(iPropName);
            else
                linkedInstance = data.(iPropName);
                schemaName = class(instance.(iPropName));
                if ~isa(linkedInstance, 'openminds.abstract.Schema')
                    if isempty(linkedInstance)
                        linkedInstance = feval(sprintf('%s.empty', schemaName));
                    else
                        keyboard
                        %schemaInstance = metadataCollection.getInstanceFromLabel(schemaName, label);
                    end
                end
                
                instance.(iPropName) = linkedInstance;
            end
        end
    end
end


function tf = isSchemaInstanceUnavailable(value)
    tf = ~isempty(regexp(char(value), 'No \w* available', 'once'));
end