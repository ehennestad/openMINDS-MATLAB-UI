classdef ParameterSet < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/ParameterSet"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'context', 'relevantFor', 'parameter'}
    end

    properties
        % Enter the common context for the parameters grouped in this set.
        context (1,1) string

        % Add the technique or behavioral task where this set of parameters is used in.
        relevantFor (1,1) {openminds.core.BehavioralTask, openminds.controlledTerms.Technique}

        % Add all numerical and string parameters that belong to this parameter set.
        parameter (1,:) {openminds.core.NumericalParameter, openminds.core.StringParameter}
    end

    methods
        function obj = ParameterSet()
        end
    end

end