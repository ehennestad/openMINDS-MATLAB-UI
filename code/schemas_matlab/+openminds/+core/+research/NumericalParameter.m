classdef NumericalParameter < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/NumericalParameter"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'name', 'value'}
    end

    properties
        % Enter a descriptive name for this numerical parameter.
        name (1,1) string

        % Add at least one quantitative value for this parameter.
        value (1,:) {openminds.core.QuantitativeValue, openminds.core.QuantitativeValueRange}
    end

    methods
        function obj = NumericalParameter()
        end
    end

end