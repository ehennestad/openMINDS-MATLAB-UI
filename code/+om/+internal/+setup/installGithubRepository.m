function installGithubRepository(repositoryUrl, branchName)

    arguments
        repositoryUrl (1,1) string
        branchName (1,1) string = "master"
    end

    if ismissing(branchName); branchName = "master"; end

    repoName = string( regexp(repositoryUrl, '[^/]+$', 'match', 'once') );
    
    % Check if this repo is already on path:
    pathList = strsplit(path, pathsep);
    match = regexp(pathList, repoName+"$" ); % Like this???
    
    isEmpty = cellfun('isempty', match);
    matchIdx = find(~isEmpty);

    % Todo: Check for presence of Readme.md and LICENSE
    
    % Todo: How to deal with different branches?

    targetFolder = om.internal.constant.AddonTargetFolder();
    repoTargetFolder = fullfile(targetFolder, repoName);

    if ~isfolder(repoTargetFolder); mkdir(repoTargetFolder); end

    downloadUrl = sprintf( '%s/archive/refs/heads/%s.zip', repositoryUrl, branchName );

    om.internal.setup.downloadZippedGithubRepo(downloadUrl, repoTargetFolder, true, true);
    
    % Run setup.m if present.
    if isfile( fullfile(repoTargetFolder, 'setup.m') )
        run( fullfile(repoTargetFolder, 'setup.m') )
    else
        addpath(genpath(repoTargetFolder)); savepath()
    end
end
