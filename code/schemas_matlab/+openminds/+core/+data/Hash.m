classdef Hash < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/Hash"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'algorithm', 'digest'}
    end

    properties
        % Enter the algorithm used to generate this hash.
        algorithm (1,1) string

        % Enter the digest of this hash.
        digest (1,1) string
    end

    methods
        function obj = Hash()
        end
    end

end