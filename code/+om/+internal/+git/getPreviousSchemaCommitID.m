function commitID = getPreviousSchemaCommitID()

    openMindsFolderPath = om.Constants.getRootPath();
    schemaFolderPath = fullfile(openMindsFolderPath, 'schemas');
    filePath = fullfile(schemaFolderPath, 'schema_prev_commit_id.json');
    
    if isfile(filePath)
        S = jsondecode( fileread(filePath) );
        commitID = S.CommitID;
    else
        commitID = '';
    end
end