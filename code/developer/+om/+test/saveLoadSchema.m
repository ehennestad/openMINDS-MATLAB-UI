function T = saveLoadSchema()
    
    moduleName = 'core';
    schemaList = om.dir.schema(moduleName);

    numSchemas = numel(schemaList);

    tempsavepath = tempname;
    tempsavepath = [tempsavepath, '.mat'];
    disp(tempsavepath)
    C = onCleanup(@(filepath)delete(tempsavepath));

    numTestsFailed = 0;

    C = cell(0, 4);

    for i = 1:numSchemas
        
        schemaClassFunctionName = om.strutil.buildClassName(schemaList(i).Name, schemaList(i).Category, moduleName);
        schemaFcn = str2func(schemaClassFunctionName);
        
        mc = meta.class.fromName(schemaClassFunctionName);
        if mc.Abstract; continue; end

        try
            itemPreSave = schemaFcn();
        catch ME
            %fprintf('Could not create object for %s\n', schemaList(i).Name)
            %disp(getReport(ME))
            numTestsFailed = numTestsFailed + 1;

            %C{numTestsFailed, 1} = schemaList(i).Name;
            C{numTestsFailed, 1} = schemaClassFunctionName;
            C{numTestsFailed, 2} = 'Create object';
            C{numTestsFailed, 3} = ME.message;
            C{numTestsFailed, 4} = getReport(ME);
            continue
        end

        try 
            save(tempsavepath, 'itemPreSave');
        catch ME
            %fprintf('Could not save object for %s\n', schemaList(i).Name)
            %disp(getReport(ME))
            numTestsFailed = numTestsFailed + 1;

            %C{numTestsFailed, 1} = schemaList(i).Name;
            C{numTestsFailed, 1} = schemaClassFunctionName;
            C{numTestsFailed, 2} = 'Save object';
            C{numTestsFailed, 3} = ME.message;
            C{numTestsFailed, 4} = getReport(ME);            
            continue
        end

        S = load(tempsavepath, 'itemPreSave');

        if isequal(S.itemPreSave, itemPreSave)
            %fprintf('Test passed for %s\n', schemaList(i).Name)
        else
            %fprintf('Test failed for %s\n', schemaList(i).Name)
            numTestsFailed = numTestsFailed + 1;

            C{numTestsFailed, 1} = schemaClassFunctionName;
            C{numTestsFailed, 2} = 'Load same object';
            C{numTestsFailed, 3} = '';
            C{numTestsFailed, 4} = '';            
        end
    end

    T = cell2table(C, 'VariableNames', {'SchemaName', 'Failure point', 'Error Message', 'Extended Error'});
    fprintf('Number of tests that failed: %d\n', numTestsFailed)
end
