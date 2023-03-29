function className = createPropertyLinksetClass(propertyName, linkedTypes)
% createPropertyLinksetClass Create a new linkset class for a given property
%
% Syntax:
%   className = createPropertyLinksetClass(propertyName, linkedTypes)
%
% Inputs:
%   propertyName - The name of the property to create a linkset class for
%   linkedTypes - A string array of the types that the property links to
%
% Outputs:
%   className - The name of the newly created linkset class
%
% Example:
%   className = createPropertyLinksetClass('MyProperty', ["Type1", "Type2"])
%
% See also: openminds.abstract.LinkedCategory

    % Ensure property name is PascalCase
    propertyName(1) = upper(propertyName(1));
    
    % Convert the cell array of types to a string representing a string
    % array
    linkedTypes = om.generator.utility.cellArrayToTextStringArray(linkedTypes);

    % Define directory and file paths
    rootSourceDirectory = fullfile(om.Constants.getRootPath, 'code', 'schemas_matlab', '+openminds', '+linkset');
    rootTargetDirectory = fullfile(om.Constants.SchemaFolder, 'matlab', '+openminds', '+linkset');
    templateFilepath = fullfile(rootSourceDirectory, 'Template.m');
    saveFilepath = fullfile(rootTargetDirectory, sprintf('%s.m', propertyName));

    % Read the template
    str = fileread(templateFilepath);

    % Modify the template based on inputs
    str = strrep(str, 'Template', propertyName);
    str = strrep(str, '[]', linkedTypes);

    % Save the result to a new class
    if isfile(saveFilepath)
        warning('Property link class already exists for %s', propertyName)
        saveFilepath = strrep(saveFilepath, '.m', sprintf('%02d.m', randi(100) ));
    end
    om.internal.fileio.filewrite(saveFilepath, str)
    
    className = sprintf('openminds.linkset.%s', propertyName);
end