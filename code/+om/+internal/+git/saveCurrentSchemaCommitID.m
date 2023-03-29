function saveCurrentSchemaCommitID(commitID)
    
    if ~nargin
        commitID = om.internal.git.getCurrentCommitID('documentation');
    end
    
    openMindsFolderPath = om.Constants.getRootPath();
    schemaFolderPath = fullfile(openMindsFolderPath, 'schemas');
    filePath = fullfile(schemaFolderPath, 'schema_prev_commit_id.json');

    S = struct('LastUpdate', datestr(now), 'CommitID', commitID);
    str = jsonencode(S, 'PrettyPrint', true);
    fid = fopen(filePath, 'w');
    fwrite(fid, str);
    fclose(fid);
end
    