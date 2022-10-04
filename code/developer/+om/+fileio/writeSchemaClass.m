function writeSchemaClass(fileName, textStr)

    fid = fopen(fileName, 'w');
    fwrite(fid, textStr);
    fclose(fid);

end