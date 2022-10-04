classdef Organization < openminds.abstract.OpenMINDSSchema & core.category.LegalPerson

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/Organization"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {'legalPerson'}
    end

    properties (SetAccess = immutable)
        Required = {'fullName'}
    end

    properties
        % Add one or several globally unique and persistent digital identifier for this organization.
        digitalIdentifier (1,:) {openminds.core.GRIDID, openminds.core.RORID}

        % Enter the full name of the organization.
        fullName (1,1) string

        % Add a parent organization to this organization.
        hasParent (1,1) openminds.core.Organization

        % Add the uniform resource locator (URL) to the homepage of this organization.
        homepage (1,1) openminds.core.URL

        % Enter the short name of this organization.
        shortName (1,1) string
    end

    methods
        function obj = Organization()
        end
    end

end