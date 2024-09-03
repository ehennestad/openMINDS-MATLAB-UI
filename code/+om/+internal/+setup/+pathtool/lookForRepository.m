function [exists, repositoryPath] = lookForRepository(repositoryName, branchName)
    
    exists = false;
    repositoryPath = "";
    
    % Get the full MATLAB search path:
    pathList = strsplit(path, pathsep);

    % First, we look for the following pattern: {repositoryName}-{branchName}
    %   This should be the default name if a repository is downloaded as a
    %   zip and unzipped locally.
    %
    % If not found, search for the repository name, as would be expected if
    %   the repository is cloned from GitHub

    expectedFolderName = [ ...
        sprintf("%s-%s", repositoryName, branchName), ...
        string(repositoryName) ];
    
    for i = 1:numel(expectedFolderName)

        % Check if this repo is already on path:
        matchingFolderName = regexp(pathList, expectedFolderName(i), 'match');
        
        isEmpty = cellfun('isempty', matchingFolderName);
        matchedFolderIndex = find(~isEmpty);
    
        if numel(matchedFolderIndex) == 1
            exists = true;
            repositoryPath = pathList{matchedFolderIndex}; 
            break

        elseif numel(matchedFolderIndex) > 1
            warning('Multiple folders matching the repository name was found on path')
            exists = true;
            repositoryPath = pathList(matchedFolderIndex);
            break

        end
    end
    repositoryPath = string(repositoryPath);
    
    % Make sure folder exists
    if ~isfolder(repositoryPath(1))
        warning("Repository was found on MATLAB's search path, but folder does not exist")
        exists = false;
        repositoryPath = "";
    end

    if repositoryPath == ""; return; end
    
    % Check if folder contains expected files...
    L = dir( repositoryPath(1) );
    assert(contains('README.md', {L.name}, 'IgnoreCase', true) && ...
        contains('LICENSE', {L.name}, 'IgnoreCase', true), ...
        "Expected repository to contain a Readme and LICENSE file")
end