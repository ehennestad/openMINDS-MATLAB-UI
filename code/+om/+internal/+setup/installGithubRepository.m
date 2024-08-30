function installGithubRepository(repositoryUrl, options)

    arguments
        repositoryUrl (1,1) string
        options.Update (1,1) logical = false
    end

    repoName = string( regexp(repositoryUrl, '[^/]+$', 'match', 'once') );
    
    % Check if this repo is already on path:
    pathList = strsplit(path, pathsep);
    matchingFolderName = regexp(pathList, repoName+"$" ); % Like this???
    
    isEmpty = cellfun('isempty', matchingFolderName);
    matchedFolderIndex = find(~isEmpty);

    % Todo: Check for presence of Readme.md and LICENSE
    
    if ~isempty(matchedFolderIndex)
        if options.Update

        end
    end
        

    targetFolder = om.internal.constant.AddonTargetFolder();
    repoTargetFolder = fullfile(targetFolder, repoName);

    if ~isfolder(repoTargetFolder); mkdir(repoTargetFolder); end

    downloadUrl = sprintf( '%s/archive/refs/heads/master.zip',  repositoryUrl );

    om.internal.setup.downloadZippedGithubRepo(downloadUrl, repoTargetFolder, true, true);
    
    % Run setup.m if present.
    if isfile( fullfile(repoTargetFolder, 'setup.m') )
        run( fullfile(repoTargetFolder, 'setup.m') )
    else
        addpath(genpath(repoTargetFolder)); savepath()
    end
end
