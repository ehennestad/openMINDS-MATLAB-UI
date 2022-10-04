classdef QuantitativeValueRange < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/QuantitativeValueRange"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'maxValue', 'minValue'}
    end

    properties
        % Add the maximum value measured for this range.
        maxValue (1,1) double

        % Add the minimum value measured for this range.
        minValue (1,1) double

        % Add the unit of measurement of this quantitative value range.
        unit (1,1) openminds.controlledTerms.UnitOfMeasurement
    end

    methods
        function obj = QuantitativeValueRange()
        end
    end

end