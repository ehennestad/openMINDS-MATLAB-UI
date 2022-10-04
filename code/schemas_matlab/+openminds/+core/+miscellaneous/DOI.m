classdef DOI < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/DOI"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'identifier'}
    end

    properties
        % Enter the resolvable identifier (IRI) of the International Digital Object Identifier Foundation.
        identifier (1,1) string
    end

    methods
        function obj = DOI()
        end
    end

end