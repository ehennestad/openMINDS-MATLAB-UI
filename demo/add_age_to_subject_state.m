

numSubjectStates = numel(S.MetadataSet.SchemaInstances.SubjectState);

for i = 1:numSubjectStates
    
    numDays = randi([120,180]);

    iSubjectState = S.MetadataSet.SchemaInstances.SubjectState(i);
    
    iSubjectState.age = openminds.core.miscellaneous.QuantitativeValue();
    iSubjectState.age.value = numDays;
    iSubjectState.age.unit = openminds.controlledterms.UnitOfMeasurement.day;

end

MetadataSet = S.MetadataSet; %#ok<PROP> 
save(metadataSetPath, 'MetadataSet')