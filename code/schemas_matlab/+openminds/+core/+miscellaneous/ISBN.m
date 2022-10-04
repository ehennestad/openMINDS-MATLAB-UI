classdef ISBN < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/ISBN"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'identifier'}
    end

    properties
        % Enter the International Standard Book Number (ISBN-13) of the International ISBN Agency.
        identifier (1,1) string
    end

    methods
        function obj = ISBN()
        end
    end

end