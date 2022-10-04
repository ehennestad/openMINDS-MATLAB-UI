classdef Person < openminds.abstract.OpenMINDSSchema & core.category.LegalPerson

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/Person"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {'legalPerson'}
    end

    properties (SetAccess = immutable)
        Required = {'givenName'}
    end

    properties
        % Add one or several globally unique and persistent digital identifier for this person.
        digitalIdentifier (1,:) openminds.core.ORCID

        % Add the contact information of this person.
        contactInformation (1,1) openminds.core.ContactInformation

        % Enter the family name of this person.
        familyName (1,1) string

        % Enter the given name of this person.
        givenName (1,1) string

        % Add the current and, if necessary, past affiliations of this person
        affiliation (1,:) openminds.core.Affiliation
    end

    methods
        function obj = Person()
        end
    end

end