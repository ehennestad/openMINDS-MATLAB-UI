classdef Protocol < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/Protocol"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'description', 'name', 'technique'}
    end

    properties
        % Enter a description of this protocol.
        description (1,1) string

        % Enter a descriptive name for this protocol.
        name (1,1) string

        % Add all study options this protocol offers.
        studyOption (1,:) {core.category.StudyTarget}

        % Add all techniques that were used in this protocol.
        technique (1,:) openminds.controlledTerms.Technique
    end

    methods
        function obj = Protocol()
        end
    end

end