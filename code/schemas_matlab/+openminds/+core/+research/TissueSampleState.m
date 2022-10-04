classdef TissueSampleState < openminds.core.research.SpecimenState

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/TissueSampleState"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {}
    end

    properties
    end

    methods
        function obj = TissueSampleState()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end