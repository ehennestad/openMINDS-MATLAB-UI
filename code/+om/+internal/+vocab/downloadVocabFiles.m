function downloadVocabFiles()
% downloadVocabFiles - Download openminds vocab files

    typesUrl = om.internal.vocab.constants.VocabURL("TYPES");
    propsUrl = om.internal.vocab.constants.VocabURL("PROPERTIES");

    saveFolder = fileparts(om.internal.vocab.constants.VocabFilepath);
    if ~isfolder(saveFolder); mkdir(saveFolder); end

    websave(om.internal.vocab.constants.VocabFilepath("TYPES"), typesUrl);
    websave(om.internal.vocab.constants.VocabFilepath("PROPERTIES"), propsUrl);
end