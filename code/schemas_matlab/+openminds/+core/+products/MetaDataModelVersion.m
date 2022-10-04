classdef MetaDataModelVersion < openminds.core.products.ResearchProductVersion

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/MetaDataModelVersion"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'license', 'type'}
    end

    properties
        % If necessary, add one or several developers (person or organization) that contributed to the code implementation of this (meta)data model version. Note that these developers will overwrite the once provided in the (meta)data model product this version belongs to.
        developer (1,:) {core.category.LegalPerson}

        % Add the globally unique and persistent digital identifier of this research product version.
        digitalIdentifier (1,1) {openminds.core.DOI, openminds.core.SWHID}

        % Add all (meta)data model versions that can be used alternatively to this (meta)data model version.
        isAlternativeVersionOf (1,:) openminds.core.MetaDataModelVersion

        % Add the dataset version preceding this (meta)data model version.
        isNewVersionOf (1,1) openminds.core.MetaDataModelVersion

        % Add the license for this (meta)data model version.
        license (1,1) openminds.core.License

        % Add all content types in which (meta)data compliant with this (meta)data model version can be stored in.
        serializationFormat (1,:) openminds.core.ContentType

        % Add all content types in which the schemas of this (meta)data model version are stored in.
        specificationFormat (1,:) openminds.core.ContentType

        % Add the type of this (meta)data model version.
        type (1,1) openminds.controlledTerms.MetaDataModelType
    end

    methods
        function obj = MetaDataModelVersion()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end