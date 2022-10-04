classdef ORCID < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/ORCID"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'identifier'}
    end

    properties
        % Enter the resolvable identifier (IRI) of the Open Researcher and Contributor ID, Inc.
        identifier (1,1) string
    end

    methods
        function obj = ORCID()
        end
    end

end