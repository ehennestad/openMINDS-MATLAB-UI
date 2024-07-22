function propertyName = getPropertyName(propertyNameAlias)
    
    persistent propertiesVocab

    if isempty(propertiesVocab)
        propertiesVocab = om.internal.vocab.loadVocabJson("properties");
    end

    error('Not implemented')

    if numel(propertyName) == 1
        return
    elseif isempty(propertyName)
        throwEmptyPropertyNameException(propertyNameAlias);
    else
        throwMultiplePropertyNamesException(propertyNameAlias);
    end
end

function throwEmptyPropertyNameException(propertyNameAlias)
    error('OPENMINDS_UI:PropertyNameNotFound', 'No property name matching "%s" was found.', propertyNameAlias);
end

function throwMultiplePropertyNamesException(propertyNameAlias)
    error('OPENMINDS_UI:MultiplePropertyNamesFound', 'Multiple property names matched "%s".', propertyNameAlias)
end

