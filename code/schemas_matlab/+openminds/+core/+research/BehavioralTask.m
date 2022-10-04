classdef BehavioralTask < openminds.abstract.OpenMINDSSchema & core.category.FileOrigin

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/BehavioralTask"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {'fileOrigin'}
    end

    properties (SetAccess = immutable)
        Required = {'description', 'fullName'}
    end

    properties
        % Enter a description of this behavioral task.
        description (1,1) string

        % Enter a descriptive full name for this behavioral task.
        fullName (1,1) string

        % Enter a short name (alias) for this behavioral task.
        shortName (1,1) string
    end

    methods
        function obj = BehavioralTask()
        end
    end

end