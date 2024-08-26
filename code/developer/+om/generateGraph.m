function [G, edgeLabels] = generateGraph(moduleName, force)

    % Save graph
    % Modify schemas to include incoming links/edges.

    arguments
        moduleName = 'core'
        force = false
    end

    [s, t, e] = deal(cell(0,1));

    types = enumeration( 'om.enum.Types' );
    classNames = [types.ClassName];
    keep = startsWith( classNames, sprintf('openminds.%s', moduleName) );
    classNames = classNames(keep);

    numTypes = numel(classNames);

    for i = 1:numTypes
        classFcn = str2func(classNames(i));
        
        try
            tempObj = classFcn();

            propertyNames = properties(tempObj);

            for j = 1:numel(propertyNames)
                iValue = tempObj.(propertyNames{j});

                [~, ~, sourceName] = fileparts( class(tempObj) );

                if isa(iValue, 'openminds.abstract.Schema') && ~isa(iValue, 'openminds.controlledterm.ControlledTerm')
                    [~, ~, targetName] = fileparts( class(iValue) );

                    s{end+1} = sourceName(2:end); %#ok<AGROW> 
                    t{end+1} = targetName(2:end); %#ok<AGROW> 
                    e{end+1} = propertyNames{j}; %#ok<AGROW> 
                elseif isa(iValue, 'openminds.internal.abstract.LinkedCategory')

                    allowedTypes = eval(sprintf("%s.ALLOWED_TYPES", class(iValue)));

                    for k = 1:numel(allowedTypes)
                        [~, ~, targetName] = fileparts( allowedTypes{k} );
                        
                        s{end+1} = sourceName(2:end); %#ok<AGROW> 
                        t{end+1} = targetName(2:end); %#ok<AGROW> 
                        e{end+1} = propertyNames{j}; %#ok<AGROW> 
                    end
                end
            end
        end
    end

    G = digraph(s,t);
    if nargout == 2
        edgeLabels = e;
    end
end