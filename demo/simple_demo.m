% % Create a new demo subject
% subject1 = openminds.core.research.Subject(...
%     'species', 'musMusculus', ...
%     'biologicalSex', 'male', ...
%     'lookupLabel', 'demo_subject1');
% 
% ts1 = openminds.core.research.TissueSample(...
%     'species', 'musMusculus', ...
%     'biologicalSex', 'male', ...
%     'lookupLabel', 'demo_tissue_sample1');
% 
% % Create the first subject state for the demo subject
% subjectStateA = openminds.core.research.SubjectState(...
%     'ageCategory', 'adult', ...
%     'attribute', 'alive', ...
%     'lookupLabel', 'demo-subject-stateA');
% 
% % Add the subject state to the studied state of the subject
% subject1.studiedState = subjectStateA;
% 
% % Display the newly created subject
% disp(subject1)

import openminds.core.research.*
import openminds.core.*

% Create a new demo subject
subject1 = Subject('species', 'musMusculus', 'biologicalSex', 'male', 'lookupLabel', 'demo_subject1');

% Create the first subject state for the demo subject
subjectStateA = SubjectState('ageCategory', 'adult', 'attribute', 'alive', 'lookupLabel', 'demo-subject-stateA');
subjectStateA.age = openminds.core.miscellaneous.QuantitativeValue('value', 2, 'unit', openminds.controlledterms.UnitOfMeasurement.day);
subjectStateB = SubjectState('ageCategory', 'adult', 'attribute', 'alive', 'lookupLabel', 'demo-subject-stateB');
subjectStateC = SubjectState('ageCategory', 'adult', 'attribute', 'alive', 'lookupLabel', 'demo-subject-stateC');
subjectStateD = SubjectState('ageCategory', 'adult', 'attribute', 'alive', 'lookupLabel', 'demo-subject-stateD');
subjectStateE = SubjectState('ageCategory', 'adult', 'attribute', 'alive', 'lookupLabel', 'demo-subject-stateE');
subjectStateF = SubjectState('ageCategory', 'adult', 'attribute', 'alive', 'lookupLabel', 'demo-subject-stateF');
subjectStateG = SubjectState('ageCategory', 'adult', 'attribute', 'alive', 'lookupLabel', 'demo-subject-stateG');
subjectStateH = SubjectState('ageCategory', 'adult', 'attribute', 'alive', 'lookupLabel', 'demo-subject-stateH');

% Add the subject state to the studied state of the subject
subject1.studiedState = subjectStateA;
subject1.studiedState = [subjectStateA,subjectStateB];


% Display the newly created subject
disp(subject1)




ts1 = openminds.core.research.TissueSample(...
    'species', 'musMusculus', ...
    'biologicalSex', 'male', ...
    'lookupLabel', 'demo_tissue_sample1');
