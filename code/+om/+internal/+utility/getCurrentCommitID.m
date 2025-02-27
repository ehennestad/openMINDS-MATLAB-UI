function [commitID, commitDetails] = getCurrentCommitID(options)
%getCurrentCommitID Get current commit id for a branch of the openminds repo
%
%   commitID = getCurrentCommitID(BranchName, branchName) returns the commitID 
%   for the specified branch as a character vector
    
    arguments
        options.BranchName = "main"
    end

    [commitID, commitDetails] = ...
        matbox.setup.internal.github.api.getCurrentCommitID(...
            "openMINDS-MATLAB-UI", ...
            'BranchName', options.BranchName, ...
            'UserName', "ehennestad");

    if nargout < 2
        clear commitDetails
    end
end
