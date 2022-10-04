classdef SubjectState < openminds.core.research.SpecimenState

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/SubjectState"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'ageCategory'}
    end

    properties
        % Add the age category of the subject in this state.
        ageCategory (1,1) openminds.controlledTerms.AgeCategory

        % Add the preferred hand of the subject in this state.
        handedness (1,1) openminds.controlledTerms.Handedness
    end

    methods
        function obj = SubjectState()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end