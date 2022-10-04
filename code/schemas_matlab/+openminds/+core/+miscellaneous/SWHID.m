classdef SWHID < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/SWHID"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'identifier'}
    end

    properties
        % Enter the resolvable identifier (IRI) of the Software Heritage archive.
        identifier (1,1) string
    end

    methods
        function obj = SWHID()
        end
    end

end