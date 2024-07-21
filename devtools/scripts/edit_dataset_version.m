addpath( genpath( fullfile(fileparts(openminds.internal.rootpath), 'tests') ) )

filePath = fullfile(userpath, "openMINDS_MATLAB", "demo", "datasetversion_gui.jsonld");

if ~isfile(filePath)
    persons = personArray; % openminds/tests/oneOff
    
    dsv = openminds.core.DatasetVersion();
    dsv.author = persons;
    
    collection = openminds.Collection();
    collection.add(dsv)
    collection.save(filePath)
else
    collection = openminds.Collection(filePath);
    dsv = collection.list("DatasetVersion");
end

dsv = om.uiCreateNewInstance(dsv, dsv.X_TYPE, collection);

collection.save(filePath)