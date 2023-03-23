function str = getSchemaDocLink(schemaClass, preferredDocumentation)
    
    if nargin < 2
        %preferences.PreferredDocumentation = 'Command window help';
        preferences.PreferredDocumentation = 'Default browser';
        preferredDocumentation = preferences.PreferredDocumentation;
    end

    if strncmp( schemaClass, 'https', 5)
        schemaClass = convertToMatlabClassname(schemaClass);
    end

    if ~strncmp(schemaClass, 'openminds', 9)
        str = schemaClass; return
    end

    switch preferredDocumentation
        case 'Command window help'
            str = getSimpleHelpLink(schemaClass);

        case 'Help popup'
            str = getHelpPopupLink(schemaClass);

        case 'Matlab web'
            str = getHtmlLink(schemaClass, '-new -notoolbar');

        case 'Default browser'
            str = getHtmlLink(schemaClass, '-browser');
    end
end


function str = getSimpleHelpLink(schemaClass)
    schemaName = openminds.abstract.Schema.getSchemaShortName(schemaClass);
    str = sprintf('<a href="matlab:help %s" style="font-weight:bold">%s</a>', schemaClass, schemaName);
end

function str = getHelpPopupLink(schemaClass)
    schemaName = openminds.abstract.Schema.getSchemaShortName(schemaClass);
    str = sprintf('<a href="matlab:helpPopup %s" style="font-weight:bold">%s</a>', schemaClass, schemaName);
end

function str = getHtmlLink(schemaClass, browserOption)
    
    persistent htmlFileTable
    if isempty(htmlFileTable)
        htmlFileTable = om.internal.dir.listSourceSchemas(...
            'SchemaType', 'html', 'SchemaFileExtension', 'html');
    end
    
    schemaName = openminds.abstract.Schema.getSchemaShortName(schemaClass);

    isMatch = lower(htmlFileTable.SchemaName) == lower(schemaName);
    filepath = htmlFileTable.Filepath(isMatch);
    
    %commandStr = sprintf('web(''%s'', ''%s'')', filepath, browserOption);
    str = sprintf('<a href="matlab:web %s %s" style="font-weight:bold">%s</a>', filepath, browserOption, schemaName);
end

function schemaClass = convertToMatlabClassname(schemaClass)
    schemaClass = strrep(schemaClass, 'https://openminds.ebrains.eu/', '');
    splitStr = strsplit(schemaClass, '/');

    modelName = lower(splitStr{1});
    schemaName = splitStr{2};

    schemaClass = strjoin({'openminds', modelName, schemaName}, '.');
end
