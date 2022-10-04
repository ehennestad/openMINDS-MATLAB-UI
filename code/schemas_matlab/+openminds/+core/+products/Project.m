classdef Project < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/Project"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'description', 'fullName', 'hasResearchProducts', 'shortName'}
    end

    properties
        % Enter a description of this project.
        description (1,1) string

        % Enter a descriptive full name (title) for this project.
        fullName (1,1) string

        % Add all research products or research product versions that are part of this project.
        hasResearchProducts (1,:) {openminds.core.Dataset, openminds.core.DatasetVersion, openminds.core.MetaDataModel, openminds.core.MetaDataModelVersion, openminds.core.Model, openminds.core.ModelVersion, openminds.core.Software, openminds.core.SoftwareVersion}

        % Add the uniform resource locator (URL) to the homepage of this project.
        homepage (1,1) openminds.core.URL

        % Add one or several project coordinators (person or organization).
        coordinator (1,:) {core.category.LegalPerson}

        % Enter a short name (alias) for this project.
        shortName (1,1) string
    end

    methods
        function obj = Project()
        end
    end

end