function G = generateGraph(moduleName, force)

    % Save graph
    % Modify schemas to include incoming links/edges.

    arguments
        moduleName = 'core'
        force = false
    end

    [s, t, e] = deal(cell(0,1));


    schemaList = om.dir.schema(moduleName);

    numSchemas = numel(schemaList);

    for i = 1:numSchemas
        className = om.strutil.buildClassName(schemaList(i).Name, schemaList(i).Category, moduleName);
        classFcn = str2func(className);
        
        try
            tempObj = classFcn();

            propertyNames = properties(tempObj);

            for j = 1:numel(propertyNames)
                iValue = tempObj.(propertyNames{j});

                if isa(iValue, 'openminds.abstract.OpenMINDSSchema') && ~isa(iValue, 'openminds.controlledterm.ControlledTerm')
                    s{end+1} = class(tempObj); %#ok<AGROW> 
                    t{end+1} = class(iValue); %#ok<AGROW> 
                    e{end+1} = propertyNames{j}; %#ok<AGROW> 
                end
            end
        end
    end

    G = digraph(s,t);
end