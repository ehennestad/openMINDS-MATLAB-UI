classdef SubjectGroup < openminds.core.research.SpecimenSet

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/SubjectGroup"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'studiedState'}
    end

    properties
        % Add all states in which this subject group was studied.
        studiedState (1,:) openminds.core.SubjectGroupState
    end

    methods
        function obj = SubjectGroup()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end