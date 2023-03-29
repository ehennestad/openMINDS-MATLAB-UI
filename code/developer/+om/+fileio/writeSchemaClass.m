function writeSchemaClass(fileName, textStr)

    folderPath = fileparts(fileName);
    
    if ~exist(folderPath, 'dir')
        mkdir(folderPath)
    end

    fid = fopen(fileName, 'w');
    fwrite(fid, textStr);
    fclose(fid);

end