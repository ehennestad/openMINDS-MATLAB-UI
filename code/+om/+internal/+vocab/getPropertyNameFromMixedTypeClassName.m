function propertyName = getPropertyNameFromMixedTypeClassName(mixedTypeClassName)
% getPropertyNameFromMixedTypeClassName - Get property name from a mixed type class name
    arguments
        mixedTypeClassName (1,1) string
    end

    mixedTypeClassNameSplit = strsplit(mixedTypeClassName, '.');
    propertyName = om.internal.vocab.getPropertName( mixedTypeClassNameSplit{end} );
end
