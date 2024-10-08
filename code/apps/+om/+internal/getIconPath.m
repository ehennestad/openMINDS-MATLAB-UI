function iconFilePath = getIconPath(name)
%getLogoPath - Get filepath for an icon resource
    arguments
        name (1,1) string 
    end
    rootPath = fullfile(om.internal.rootpath, 'apps');
    iconFolderPath = fullfile(rootPath, 'resources', 'icons');
    L = dir(fullfile(iconFolderPath, sprintf('%s.*', name)));
    if isempty(L)
        error('No icon with name "%s" was found', name)
    end

    %fileName = sprintf('%s.png', name);
    iconFilePath = fullfile(iconFolderPath, L.name);
end