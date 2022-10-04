classdef URL < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/URL"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'URL'}
    end

    properties
        % Enter a uniform resource locator (URL).
        URL (1,1) string
    end

    methods
        function obj = URL()
        end
    end

end