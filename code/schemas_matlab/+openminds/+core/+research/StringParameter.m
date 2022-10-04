classdef StringParameter < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/StringParameter"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'name', 'value'}
    end

    properties
        % Enter a descriptive name for this parameter.
        name (1,1) string

        % Enter a text value for this parameter.
        value (1,1) string
    end

    methods
        function obj = StringParameter()
        end
    end

end