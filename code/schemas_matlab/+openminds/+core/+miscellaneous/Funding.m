classdef Funding < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/Funding"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'funder'}
    end

    properties
        % Enter the acknowledgement that should be used with this funding.
        acknowledgement (1,1) string

        % Enter the associated award number of this funding.
        awardNumber (1,1) string

        % Enter the award title of this funding.
        awardTitle (1,1) string

        % Add the organization that provided this funding.
        funder (1,1) {core.category.LegalPerson}
    end

    methods
        function obj = Funding()
        end
    end

end