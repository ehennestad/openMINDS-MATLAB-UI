classdef Subject < openminds.core.research.Specimen

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/Subject"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'studiedState'}
    end

    properties
        % Add all subject groups of which this subject is a member.
        isPartOf (1,:) openminds.core.SubjectGroup

        % Add all states in which this subject was studied.
        studiedState (1,:) openminds.core.SubjectState
    end

    methods
        function obj = Subject()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end