function readVocabTypes()


    openMindsDirectory = om.Constants.getRootPath();
    schemaDirectory = fullfile(openMindsDirectory, 'schemas', 'source');

    jsonStr = fileread( fullfile(schemaDirectory, 'types.json') );

    types = om.json.decode( jsonStr );

    schemaTypes = fieldnames(props);
    numRows = numel(schemaTypes);
    
    % Todo. Get all structs into a cell array

    % Use structcat

    % Convert to table and format row names.

    AA = structfun( @(s) struct2table(s, 'AsArray', true), types, 'UniformOutput', false)
    
end