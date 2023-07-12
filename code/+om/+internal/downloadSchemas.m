function downloadSchemas()
    
    % Todo: Specify version

    import om.external.fex.filedownload.downloadFile

    % - Get some path/uri constants
    schemaURI = matlab.net.URI( om.Constants.SchemaURL );
    openMindsFolderPath = om.Constants.getRootPath();
    
    % - Create path for saving and download schemas
    downloadFolderPath = fullfile(openMindsFolderPath, 'downloads');
    zipFileName = schemaURI.Path(end);
    savePath = fullfile(downloadFolderPath, zipFileName);

    if ~isfolder(downloadFolderPath); mkdir(downloadFolderPath); end

    downloadFile(savePath, schemaURI.EncodedURI)

    % - Unzip downloaded file
    schemaFolderPath = fullfile(openMindsFolderPath, 'schemas', 'source');
    if ~isfolder(schemaFolderPath); mkdir(schemaFolderPath); end
    
    % Todo: Unzip file in a new folder and then do diff on all schema.tpl
    % files.

    unzip(savePath, schemaFolderPath)
    delete(savePath)
    
    % Save the current commit ID
    %om.internal.git.saveCurrentSchemaCommitID()
end