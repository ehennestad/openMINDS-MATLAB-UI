function setup(mode, options)
% setup - Setup/install openMINDS_MATLAB_UI

% Note: This is only needed if the code is cloned from GitHub. If you have
% installed using an mltbx file the toolbox is already properly set up

    arguments (Repeating)
        mode (1,1) string {mustBeMember(mode, ["savepath", "s"])};
    end

    arguments
        options.SavePathDef (1,1) logical = false 
    end

    mode = string(mode);

    if any(mode == "s") || any(mode == "savepath")
        options.SavePathDef = true;
        mode = setdiff(mode, ["s", "savepath"], 'stable');
    end

    installMatBox()

    toolboxFolder = fileparts(mfilename('fullpath'));
    matbox.installRequirements(toolboxFolder, mode{:})

    addpath(genpath(fullfile(toolboxFolder, 'code')))

    if options.SavePathDef
        savepath()
    end

    matbox.runStartup(toolboxFolder)
end

function installMatBox()
    addonsTable = matlab.addons.installedAddons();
    isMatchedAddon = addonsTable.Name == "MatBox";

    if ~isempty(isMatchedAddon) && any(isMatchedAddon)
        matlab.addons.enableAddon('MatBox')
    else
        info = webread('https://api.github.com/repos/ehennestad/MatBox/releases/latest');
        assetNames = {info.assets.name};
        isMltbx = startsWith(assetNames, 'MatBox');

        mltbx_URL = info.assets(isMltbx).browser_download_url;

        % Download matbox
        tempFilePath = websave(tempname, mltbx_URL);
        cleanupObj = onCleanup(@(fp) delete(tempFilePath));

        % Install toolbox
        matlab.addons.install(tempFilePath);
    end
end
