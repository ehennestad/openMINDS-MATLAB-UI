function update(mode)
%UPDATE Updates openMINDS schemas if necessary.
%
%   om.update() checks the commit ID for the previous schema update and the
%   current commit ID of the 'documentation' branch of the openMINDS github 
%   repository. If they are the same and the mode is not 'force', it displays 
%   a message indicating that the schemas are up to date. Otherwise, it proceeds 
%   with updating the schemas.
%
%   om.update(mode) allows specifying the update mode. The default mode is
%   'default', but setting it to 'force' forces the update regardless of
%   the commit IDs.
%
%   Example:
%       om.update()
%       om.update('force')


    arguments
        mode (1,1) string = "default"
    end

    % - Check commitID, and return if previous commit is is same as current
    previousCommitID = om.internal.git.getPreviousSchemaCommitID();
    currentCommitID = om.internal.git.getCurrentCommitID('documentation');

    if isequal(previousCommitID, currentCommitID) && mode ~= "force"
        disp('Schemas are up to date.')
    
    elseif isempty(previousCommitID)
        disp('Downloading openMINDS schemas.')
        om.internal.downloadSchemas()

        disp('Generating openMINDS schemas.')
        om.generateSchemas()
           
        disp('Finished!')
    else
        disp('Downloading openMINDS schemas.')
        om.internal.downloadSchemas()
        
        disp('Updating openMINDS schemas.')
        %om.updateSchemas()

        % Temporary (om.updateSchemas is not implemented yet)
        schemaFolderPath = fullfile(om.Constants.SchemaFolder, 'matlab', '+openminds');
        if isfolder(schemaFolderPath)
            rmdir(schemaFolderPath, 's' )
        end
        om.generateSchemas()

        disp('Finished!')
    end

    om.internal.git.saveCurrentSchemaCommitID()

    % Check that the schemafolder in on path
    currentPathList = strsplit(path, pathsep);

    if ~any(strcmp(currentPathList, om.Constants.SchemaFolder))
        addpath(genpath(om.Constants.SchemaFolder))
    end
    
end

% Todo: If updating, need to keep old schemas until update is complete.