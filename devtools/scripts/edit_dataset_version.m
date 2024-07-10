addpath( genpath( fullfile(fileparts(openminds.internal.rootpath), 'tests') ) )
persons = personArray; % openminds/tests/oneOff

dsv = openminds.core.DatasetVersion();
dsv.author = persons;

om.uiCreateNewInstance(dsv, openminds.MetadataCollection);
