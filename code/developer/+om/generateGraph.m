function [G, edgeLabels] = generateGraph(moduleName, force)

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

                if isa(iValue, 'openminds.abstract.Schema') && ~isa(iValue, 'openminds.controlledterm.ControlledTerm')
                    [~, ~, sourceName] = fileparts( class(tempObj) );
                    [~, ~, targetName] = fileparts( class(iValue) );

                    s{end+1} = sourceName(2:end); %#ok<AGROW> 
                    t{end+1} = targetName(2:end); %#ok<AGROW> 
                    e{end+1} = propertyNames{j}; %#ok<AGROW> 
                end
            end
        end
    end

    G = digraph(s,t);
    if nargout == 2
        edgeLabels = e;
    end
end