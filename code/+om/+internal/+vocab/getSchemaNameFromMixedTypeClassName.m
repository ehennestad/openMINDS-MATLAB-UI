function schemaName = getSchemaNameFromMixedTypeClassName(mixedTypeClassName)
% getSchemaNameFromMixedTypeClassName - Get schema name from a mixed type class name
    arguments
        mixedTypeClassName (1,1) string
    end

    mixedTypeClassNameSplit = strsplit(mixedTypeClassName, '.');
    schemaName = om.internal.vocab.getSchemaName( mixedTypeClassNameSplit{end-1} );
end