function addDependenciesToPath()

    installationLocation = om.internal.constant.AddonTargetFolder();

    % Add everything to path, so that recursiveDir can be used below
    s=warning('off');
    addpath(genpath(installationLocation));
    warning(s)

    % Lookfor startup files..
    startupListing = recursiveDir(installationLocation, ...
        'Expression', '^startup', ...
        'FileType', 'm', ...
        'RecursionDepth', 3, ...
        'OutputType', 'FilePath');

    for i = 1:numel(startupListing)
        run(startupListing{i})
    end
end
