addpath( genpath( fullfile(fileparts(openminds.internal.rootpath), 'tests') ) )
persons = personArray; % openminds/tests/oneOff

dsv = openminds.core.DatasetVersion();
dsv.author = persons;

collection = openminds.Collection();
collection.add(dsv)

om.uiCreateNewInstance(dsv, dsv.X_TYPE, collection);
