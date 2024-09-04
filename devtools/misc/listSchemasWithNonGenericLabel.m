function S = listSchemasWithNonGenericLabel()
        
    types = enumeration('om.enum.Types');
    types = types(2:end); % Exclude NONE
    numTypes = numel(types);
    
    tempsavepath = tempname;
    tempsavepath = [tempsavepath, '.mat'];
    
    %disp(tempsavepath)
    cleanupObj = onCleanup(@(filepath)delete(tempsavepath));

    numTestsFailed = 0;
    numTestsTotal = 0;

    C = cell(0, 4);
    count = 0;
    S = struct;

    for i = 1:numTypes
        schemaClassFunctionName = types(i).ClassName;
        schemaFcn = str2func(schemaClassFunctionName);
        
        iSchemaName = string(types(i));

        mc = meta.class.fromName(schemaClassFunctionName);
        if mc.Abstract; continue; end
        
        try
            count = count+1;
            itemPreSave = schemaFcn();

            if isprop(itemPreSave, 'lookupLabel')
                S.(iSchemaName).propertyName = "lookupLabel";
                S.(iSchemaName).stringFormat = "sprintf('%s', lookupLabel)";

                %pass
            elseif isprop(itemPreSave, 'fullName')
                S.(iSchemaName).propertyName = 'fullName';
                S.(iSchemaName).stringFormat = "sprintf('%s', fullName)";

                %pass
            elseif isprop(itemPreSave, 'identifier')
                S.(iSchemaName).propertyName = 'identifier';
                S.(iSchemaName).stringFormat = "sprintf('%s', identifier)";
                
                %pass
            elseif isprop(itemPreSave, 'name')
                S.(iSchemaName).propertyName = 'name';
                S.(iSchemaName).stringFormat = "sprintf('%s', name)";


                %pass
            else

                S.(iSchemaName).propertyName = '';
                S.(iSchemaName).stringFormat = "";

                fprintf('%s\n', iSchemaName)
            end


        catch ME

            fprintf('Could not create schema %s\n', iSchemaName)
        end

        
    end

    %T = cell2table(C, 'VariableNames', {'SchemaName', 'Failure point', 'Error Message', 'Extended Error'});
    %fprintf('Number of tests that failed: %d/%d\n', numTestsFailed, numTestsTotal)
end
