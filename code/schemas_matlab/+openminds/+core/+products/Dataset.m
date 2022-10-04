classdef Dataset < openminds.core.products.ResearchProduct

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/Dataset"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'author'}
    end

    properties
        % Add one or several authors (person or organization) that contributed to the production and publication of this dataset.
        author (1,:) {core.category.LegalPerson}

        % Add the globally unique and persistent digital identifier of this research product. Note that this digital identifier will be used to reference all attached research product versions.
        digitalIdentifier (1,1) openminds.core.DOI

        % Add one or several versions of this dataset.
        hasVersion (1,:) openminds.core.DatasetVersion
    end

    methods
        function obj = Dataset()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end