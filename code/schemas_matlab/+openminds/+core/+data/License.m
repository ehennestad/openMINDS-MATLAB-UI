classdef License < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/License"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'fullName', 'legalCode', 'shortName'}
    end

    properties
        % Enter the full name of this license.
        fullName (1,1) string

        % Enter the internationalized resource identifier (IRI) pointing to the legal code of this license.
        legalCode (1,1) string

        % Enter the short name of this license.
        shortName (1,1) string

        % Enter one or several webpages related to this license (e.g. homepage).
        webpage (1,:) string
    end

    methods
        function obj = License()
        end
    end

end