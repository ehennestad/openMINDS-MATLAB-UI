function folderPath = getModuleDirectory(moduleName)
%GETMODULEDIRECTORY Summary of this function goes here
%   Detailed explanation goes here
    
    arguments
        moduleName = 'core'
    end
    
    rootDirectory = om.Preferences.get('SourceDirectory');

    switch moduleName 
        case {'controlledTerms', 'controlledterms'}
            folderName = 'openMINDS_controlledTerms';
        case {'core', 'Core'}
            folderName = 'openMINDS_core';
        case ''
            folderName = 'openMINDS';

        otherwise
            error('Module is not implemented yet')
    end
    
    folderPath = fullfile(rootDirectory, folderName);

    %if ~isfolder(folderPath); mkdir(folderPath); end

end

