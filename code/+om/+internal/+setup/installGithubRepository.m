function installGithubRepository(repositoryUrl)

    repoName = string( regexp(repositoryUrl, '[^/]+$', 'match', 'once') );
    
    % Check if this repo is already on path:
    pathList = strsplit(path, pathsep);
    match = regexp(pathList, repoName+"$" ); % Like this???
    
    isEmpty = cellfun('isempty', match);
    matchIdx = find(~isEmpty);

    % Todo: Check for presence of Readme.md and LICENSE
    

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
