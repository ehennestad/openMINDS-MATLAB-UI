# openMINDS-MATLAB-UI
A MATLAB graphical user interface (GUI) for openMINDS. This toolbox builds upon the [openMINDS_MATLAB](https://github.com/openMetadataInitiative/openMINDS_MATLAB) toolkit, offering interactive forms to streamline metadata entry."

## Requirements:
MATLAB 2023a or later

## Installation
1. Clone or download this repository
2. Navigate to the repository folder in MATLAB
3. Run `setup.m`

## Getting started
This is a very minimal example on how to try out this toolbox. More examples and interactive workflows will be added later.
```
% Create a filepath to a file fro saving metadata
filePath = fullfile(userpath, "openMINDS_MATLAB", "demo", "datasetversion_gui.jsonld");

if ~isfile(filePath)
    dsv = openminds.core.DatasetVersion();
    collection = openminds.Collection();
    collection.save(filePath)
    mode = "create";
else
    collection = openminds.Collection(filePath);
    dsv = collection.list("DatasetVersion");
    mode = "modify";
end

dsv = om.uiCreateNewInstance(dsv, collection, "Mode", mode);

if ~isempty(dsv)
    collection.save(filePath)
end
```

