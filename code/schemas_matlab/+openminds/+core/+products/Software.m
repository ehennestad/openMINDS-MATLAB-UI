classdef Software < openminds.core.products.ResearchProduct

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/Software"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'developer'}
    end

    properties
        % Add one or several developers (person or organization) that contributed to the code implementation of this software.
        developer (1,:) {core.category.LegalPerson}

        % Add the globally unique and persistent digital identifier of this research product. Note that this digital identifier will be used to reference all attached research product versions.
        digitalIdentifier (1,1) {openminds.core.DOI, openminds.core.SWHID}

        % Add one or several versions of this software tool.
        hasVersion (1,:) openminds.core.SoftwareVersion
    end

    methods
        function obj = Software()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end