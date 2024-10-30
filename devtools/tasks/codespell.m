function codespell()

    projectDirectory = omuitools.projectdir();

    ignoreFileListing = dir(fullfile(projectDirectory, '*', '.codespell_ignore'));
    
    nvOptions = {};
    if ~isempty(ignoreFileListing)
        ignoreFilePath = fullfile(ignoreFileListing.folder, ignoreFileListing.name);
        nvOptions = [nvOptions, "IgnoreFilePath", ignoreFilePath];
    end

    matbox.tasks.codespellToolbox(projectDirectory, ...
        "RequireCodespellPassing", false, ...
        "Skip", ["*.prj", "*/code/+om/+external/**/*.m", "*/code/external/*"],  ...
        nvOptions{:})
end