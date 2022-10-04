classdef RORID < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/RORID"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'identifier'}
    end

    properties
        % Enter the resolvable identifier (IRI) of the Research Organization Registry.
        identifier (1,1) string
    end

    methods
        function obj = RORID()
        end
    end

end