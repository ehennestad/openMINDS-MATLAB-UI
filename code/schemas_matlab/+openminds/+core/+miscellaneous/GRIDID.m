classdef GRIDID < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/GRIDID"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'identifier'}
    end

    properties
        % Enter the resolvable identifier (IRI) of the Global Research Identifier Database.
        identifier (1,1) string
    end

    methods
        function obj = GRIDID()
        end
    end

end