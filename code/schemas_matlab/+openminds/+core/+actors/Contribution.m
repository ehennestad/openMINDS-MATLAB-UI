classdef Contribution < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/Contribution"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'contributionType', 'contributor'}
    end

    properties
        % Add one or several type of contributions made by the stated contributor.
        contributionType (1,:) openminds.controlledTerms.ContributionType

        % Add the contributing person or organization.
        contributor (1,1) {core.category.LegalPerson}
    end

    methods
        function obj = Contribution()
        end
    end

end