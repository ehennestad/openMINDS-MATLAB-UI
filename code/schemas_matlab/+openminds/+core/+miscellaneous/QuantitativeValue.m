classdef QuantitativeValue < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/QuantitativeValue"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'value'}
    end

    properties
        % Enter the measurement value of this quantitative value.
        value (1,1) double

        % Enter the measurement uncertainty of this quantitative value.
        uncertainty (1,:) number {mustBeSpecifiedLength(uncertainty, 2, 2)}

        % Add the type of uncertainty used for this quantitative value.
        typeOfUncertainty (1,1) openminds.controlledTerms.TypeOfUncertainty

        % Add the unit of measurement of this quantitative value.
        unit (1,1) openminds.controlledTerms.UnitOfMeasurement
    end

    methods
        function obj = QuantitativeValue()
        end
    end

end