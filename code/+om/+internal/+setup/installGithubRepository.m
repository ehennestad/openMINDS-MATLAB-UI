function installGithubRepository(repositoryUrl, branchName, options)

    arguments
        repositoryUrl (1,1) string
        branchName (1,1) string = "main"
        options.Update (1,1) logical = false
    end

    if ismissing(branchName); branchName = "main"; end

    [organization, repoName] = om.internal.setup.github.parseRepositoryURL(repositoryUrl);
    
    [repoExists, repoPath] = om.internal.setup.pathtool.lookForRepository(repoName, branchName);
    if repoExists
        return
    end
    
    % Todo: Implement updating
    % if repoExists
    %     if options.Update
    %         % Todo: Delete old repo and download again.
    %     else
    %         return
    %     end
    % end

    targetFolder = om.internal.constant.AddonTargetFolder();
    repoTargetFolder = fullfile(targetFolder);

    if ~isfolder(repoTargetFolder); mkdir(repoTargetFolder); end

    % Download repository
    downloadUrl = sprintf( '%s/archive/refs/heads/%s.zip', repositoryUrl, branchName );
    repoTargetFolder = om.internal.setup.downloadZippedGithubRepo(downloadUrl, repoTargetFolder, true, true);

    commitId = om.internal.setup.github.getCurrentCommitID(repoName, 'Organization', organization, "BranchName", branchName);
    filePath = fullfile(repoTargetFolder, '.commit_hash');
    om.internal.fileio.filewrite(filePath, commitId)
    
    % Run setup.m if present.
    setupFile = om.internal.setup.findSetupFile(repoTargetFolder);
    if isfile( setupFile )
        run( setupFile )
    else
        addpath(genpath(repoTargetFolder));
    end
end
