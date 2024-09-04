function T = saveLoadSchema()
    
    % Todo: move to openMINDS_MATLAB

    types = enumeration('om.enum.Types');
    numTypes = numel(types);

    tempsavepath = tempname;
    tempsavepath = [tempsavepath, '.mat'];
    
    %disp(tempsavepath)
    cleanupObj = onCleanup(@(filepath)delete(tempsavepath));

    numTestsFailed = 0;
    numTestsTotal = 0;

    C = cell(0, 4);

    for i = 1:numTypes

        schemaClassFunctionName = types(i).ClassName;
        schemaFcn = str2func( schemaClassFunctionName );
        
        try
            mc = meta.class.fromName(schemaClassFunctionName);
            if isempty(mc); continue; end
            if mc.Abstract; continue; end
        catch ME
            C{numTestsFailed, 1} = schemaClassFunctionName ;
            C{numTestsFailed, 2} = 'Get class meta info';
            C{numTestsFailed, 3} = ME.message;
            C{numTestsFailed, 4} = getReport(ME);
            continue
        end
        
        try
            itemPreSave = schemaFcn();
        catch ME
            %fprintf('Could not create object for %s\n', schemaList(i).Name)
            %disp(getReport(ME))
            numTestsFailed = numTestsFailed + 1;

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

        numTestsTotal = numTestsTotal + 3;

    end

    T = cell2table(C, 'VariableNames', {'SchemaName', 'Failure point', 'Error Message', 'Extended Error'});
    fprintf('Number of tests that failed: %d/%d\n', numTestsFailed, numTestsTotal)
end
