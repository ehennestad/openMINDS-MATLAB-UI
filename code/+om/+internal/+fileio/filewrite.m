function filewrite(filePath, textStr)             
    fid = fopen(filePath, 'w');
    fwrite(fid, textStr);
    fclose(fid);
end