
filePath = fullfile(userpath, "openMINDS_MATLAB", "demo", "datasetversion_gui.jsonld");
collection = openminds.Collection(filePath);

if isfile('test.mat')
    S = load('test.mat', 'kgCollection');
    kgCollection = S.kgCollection;
else
    kgCollection = ebrains.kg.KGCollection();
end

h = om.internal.control.InstanceDropDown(...
    "MetadataType", "Person", ...
    "MetadataCollection", collection, ...
    "Position", [1,1,300,25], ...
    "RemoteMetadataCollection", kgCollection);

person = collection.list("Person", "givenName", "Zaphod");

h = om.internal.control.InstanceDropDown(...
    "Value", person, ...
    "MetadataType", "Person", ...
    "MetadataCollection", collection, ...
    "Position", [1,1,300,25], ...
    "ActionButtonType", "InstanceEditorButton")


h = om.internal.control.InstanceDropDown(...
    "MetadataType", "openminds.internal.mixedtype.datasetversion.Author", ...
    "MetadataCollection", collection, ...
    "Position", [1,1,300,25], ...
    "ActionButtonType", "InstanceEditorButton")


h.ActionButtonType = "TypeSelectionButton"

h.Parent.Color = 'w'