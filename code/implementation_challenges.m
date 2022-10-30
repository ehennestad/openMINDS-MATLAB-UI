% controlled term instances can not be instantiated because of enumerations.
% need to either specify controlled terms with size (1,:) to create prop
% with empty value or initialize with default values... (which is sketchy).

% Categories can be used for creating heterogenous superclasses, but if
% some schemas belong to multiple categories, its a problem

% LinkedTypes / EmbeddedTypes with multiple allowed types is also a big problem.

% Schema inheritance is not compatible with matlab inheritance

% "Missing" links, i.e in openMINDS, links are unidirectional, but nodes
% with incoming edges should carry this information around. Use Olivers
% suggestion to get info about incoming links from the types endpoint of
% the kg api.

% Categories. Some categories have the wrong name, i.e core.category, when
% it should be controlledterms.category

% Some controlled terms have a name starting with letters.

% Categories...


% List of specifics in schemas and instances:


% openminds.core.data.Measurement (measurement)
%   category 'openminds.core.category.DeviceUsage' is not defined in core,
%   but in ephys...

% openminds.controlledterms.DataType - DataType.m Line: 16 Column: 9
%   enumeration name starts with number: 3DComputerGraphic('3DComputerGraphic')

% openminds.controlledterms.Technique - Technique.m Line: 16 Column: 9
% 3DComputerGraphicModeling ++

% openminds.controlledterms.EthicsAssessment - enum - EUCompliant+('EUCompliant+')
% openminds.controlledterms.SoftwareFeature  - enum - 3DGeometryDataTypes('3DGeometryDataTypes')

