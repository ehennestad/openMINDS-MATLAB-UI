% Create a metadata collection and add  instances

import openminds.core.*

%mdc = openminds.MetadataCollection();
h = om.ModelBuilder;
mdc = h.MetadataCollection;

sub1 = Subject();
sub2 = Subject();
sub3 = Subject();


substate1 = SubjectState();

subjectstateOrig = SubjectState();
substate1.descendedFrom = subjectstateOrig;
sub1.studiedState = [subjectstateOrig, substate1];

mdc.add(sub1)
mdc.add(sub2)
mdc.add(sub3)

mdc.add(substate1)


substate2 = SubjectState();
mdc.add(substate2)

sub4 = Subject();
sub4.studiedState = substate2;
mdc.add(sub4)

