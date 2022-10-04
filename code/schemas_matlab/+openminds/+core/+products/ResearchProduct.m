classdef (Abstract) ResearchProduct < openminds.abstract.OpenMINDSSchema

    properties (Access = private)
        Required = {'description', 'hasVersion', 'fullName', 'shortName'}
    end

    properties
        % Add one or several custodians (person or organization) that are responsible for this research product. Note that this custodian will be responsible for all attached research product versions.
        custodian (1,:) {core.category.LegalPerson}

        % Enter a description (abstract) for this research product (max. 2000 characters, incl. spaces; no references). Note that this description should be fitting for all attached research product versions.
        description (1,1) string

        % Enter a descriptive full name (title) for this research product.  Note that this full name should be fitting for all attached research product versions.
        fullName (1,1) string

        % Add the uniform resource locator (URL) to the homepage of this research product.
        homepage (1,1) openminds.core.URL

        % Enter the preferred citation text for this research product. Leave blank if citation text can be extracted from the assigned digital identifier.
        howToCite (1,1) string

        % Enter a short name (alias) for this research product (max. 30 characters; no space).
        shortName (1,1) string
    end

    methods
        function obj = ResearchProduct()
        end
    end

end