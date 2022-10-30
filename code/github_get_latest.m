%S = webread( 'https://api.github.com/repos/HumanBrainProject/openMINDS/commits/documentation' );
%websave('test.zip', 'https://github.com/HumanBrainProject/openMINDS/raw/documentation/openMINDS-v3.zip')

% Todo: get open minds logo from github, and add it to gitignore!
folderPath = fileparts( mfilename("fullpath") );
filePath = fullfile(folderPath, 'light_openMINDS-logo.png');
websave(filePath, 'https://github.com/HumanBrainProject/openMINDS/raw/main/img/light_openMINDS-logo.png')

