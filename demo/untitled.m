
metadataSet = om.MetadataSet();

sub1 = openminds.core.research.Subject();
sub2 = openminds.core.research.Subject();

ss1 = openminds.core.research.SubjectState();
ss2 = openminds.core.research.SubjectState();
ss3 = openminds.core.research.SubjectState();
ss4 = openminds.core.research.SubjectState();


metadataSet.add(ss1)
metadataSet.add(ss2)
metadataSet.add(ss3)
metadataSet.add(ss4)

subjectArray = [sub1, sub2];

ts1 = openminds.core.research.TissueSample();
ts2 = openminds.core.research.TissueSample();

metadataSet.add(ts1)
metadataSet.add(ts2)

tissueSampleArray = [ts1, ts2]; 


tic
metaTable = om.objectArrayToMetaTable(subjectArray);
toc

om.ModelBuilder(metadataSet, subjectArray)