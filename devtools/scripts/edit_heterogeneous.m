
%dsv = openminds.core.DatasetVersion();

cr = openminds.core.Copyright;
metadataCollection = openminds.MetadataCollection();


typeURI = cr.X_TYPE + "/" + "holder";

om.uiEditHeterogeneousList(cr.holder, typeURI, metadataCollection)