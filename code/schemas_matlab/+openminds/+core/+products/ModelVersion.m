classdef ModelVersion < openminds.core.products.ResearchProductVersion

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/ModelVersion"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'format', 'license'}
    end

    properties
        % If necessary, add one or several developers (person or organization) that contributed to the code implementation of this model version. Note that these developers will overwrite the once provided in the model product this version belongs to.
        developer (1,:) {core.category.LegalPerson}

        % Add the globally unique and persistent digital identifier of this research product version.
        digitalIdentifier (1,1) {openminds.core.DOI, openminds.core.SWHID}

        % Add the used content type of this model version.
        format (1,1) openminds.core.ContentType

        % Add the data that was used as input for this model version.
        inputData (1,:) {openminds.core.DOI, openminds.core.File, openminds.core.FileBundle}

        % Add all model versions that can be used alternatively to this model version.
        isAlternativeVersionOf (1,:) openminds.core.ModelVersion

        % Add the model version preceding this model version.
        isNewVersionOf (1,1) openminds.core.ModelVersion

        % Add at least one license for this model version.
        license (1,:) openminds.core.License

        % Add the data that was generated as output of this model version.
        outputData (1,:) {openminds.core.DOI, openminds.core.File, openminds.core.FileBundle}
    end

    methods
        function obj = ModelVersion()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end