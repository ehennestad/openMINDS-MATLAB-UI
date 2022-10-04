classdef Affiliation < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/Affiliation"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'organization'}
    end

    properties
        % Enter the start date of this affiliation.
        startDate (1,1) string

        % Enter the end date of this affiliation. Leave blank if the affiliation is still current.
        endDate (1,1) string

        % Add organization to which a person is or was affiliated.
        organization (1,1) openminds.core.Organization
    end

    methods
        function obj = Affiliation()
        end
    end

end