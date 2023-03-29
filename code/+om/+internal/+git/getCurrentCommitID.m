function commitID = getCurrentCommitID(branchName)
%getCurrentCommitID Get current commit id for a branch of the openminds repo
%
%   commitID = getCurrentCommitID(branchName) returns the commitID for the 
%   specified branch as a character vector
    
    API_BASE_URL = 'https://api.github.com/repos/HumanBrainProject/openMINDS';
    
    apiURL = strjoin( {API_BASE_URL, 'commits', branchName}, '/');

    % Get info abuout latest commit:
    %data = webread(apiURL);
    %commitID = data.sha;

    % More specific api call to only get the sha-1 hash:
    requestOpts = weboptions();
    requestOpts.HeaderFields = {'Accept', 'application/vnd.github.sha'};

    data = webread(apiURL, requestOpts);
    commitID = char(data');
end