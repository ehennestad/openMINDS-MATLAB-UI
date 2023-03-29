function update()

    % - Check commitID, and return if previous commit is is same as current
    previousCommitID = om.internal.git.getPreviousSchemaCommitID();
    currentCommitID = om.internal.git.getCurrentCommitID('documentation');

    if isequal(previousCommitID, currentCommitID)
        disp('Schemas are up to date.')
    
    elseif isempty(previousCommitID)
        disp('Downloading openMINDS schemas.')
        om.internal.downloadSchemas()

        disp('Generating openMINDS schemas.')
        om.generateSchemas()
    
    else
        disp('Downloading openMINDS schemas.')
        om.internal.downloadSchemas()

        disp('Updating openMINDS schemas.')
        om.updateSchemas()
    end

    % Check that the schemafolder in on path
    currentPathList = strsplit(path, pathsep);

    if ~any(strcmp(currentPathList, om.Constants.SchemaFolder))
        addpath(genpath(om.Constants.SchemaFolder))
    end
    
end

% Todo: If updating, need to keep old schemas until update is complete.