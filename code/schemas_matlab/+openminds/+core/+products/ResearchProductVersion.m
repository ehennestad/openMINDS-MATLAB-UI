classdef (Abstract) ResearchProductVersion < openminds.abstract.OpenMINDSSchema

    properties (Access = private)
        Required = {'accessibility', 'fullDocumentation', 'releaseDate', 'shortName', 'versionIdentifier', 'versionInnovation'}
    end

    properties
        % Add the accessibility of the data for this research product version.
        accessibility (1,1) openminds.controlledTerms.ProductAccessibility

        % Add the copyright information of this research product version.
        copyright (1,1) openminds.core.Copyright

        % Add one or several custodians (person or organization) that are responsible for this research product version.
        custodian (1,:) {core.category.LegalPerson}

        % If necessary, enter a version specific description (abstract) for this research product version (max. 2000 characters, incl. spaces; no references). If left blank, the research product version will inherit the 'description' of it's corresponding research product.
        description (1,1) string

        % Add the DOI, file or URL that points to a full documentation of this research product version.
        fullDocumentation (1,1) {openminds.core.DOI, openminds.core.File, openminds.core.URL}

        % If necessary, enter a version specific descriptive full name (title) for this research product version. If left blank, the research product version will inherit the 'fullName' of it's corresponding research product.
        fullName (1,1) string

        % Add all funding information of this research product version.
        funding (1,:) openminds.core.Funding

        % Add the uniform resource locator (URL) to the homepage of this research product version.
        homepage (1,1) openminds.core.URL

        % Enter the preferred citation text for this research product version. Leave blank if citation text can be extracted from the assigned digital identifier.
        howToCite (1,1) string

        % Enter custom keywords to this research product version.
        keyword (1,:) string {mustBeSpecifiedLength(keyword, 1, 5)}

        % Add the contributions for each involved person or organization going beyond being an author, custodian or developer of this research product version.
        otherContribution (1,:) openminds.core.Contribution

        % Add further publications besides the documentation (e.g. an original research article) providing the original context for the production of this research product version.
        relatedPublication (1,:) {openminds.core.DOI, openminds.core.ISBN}

        % Enter the date (actual or intended) of the first broadcast/publication of this research product version.
        releaseDate (1,1) string

        % Add the file repository of this research product version.
        repository (1,1) openminds.core.FileRepository

        % Enter a short name (alias) for this research product version (max. 30 characters, no space).
        shortName (1,1) string

        % Enter all channels through which a user can receive support for handling this research product.
        supportChannel (1,:) string

        % Enter the version identifier of this research product version.
        versionIdentifier (1,1) string

        % Enter a summary/description of the novelties/peculiarities of this research product version in comparison to other versions of it's research product. If this research product version is the first released version, you can enter the following disclaimer 'This is the first version of this research product.'
        versionInnovation (1,1) string
    end

    methods
        function obj = ResearchProductVersion()
        end
    end

end