classdef TissueSampleCollectionState < openminds.core.research.SpecimenState

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/TissueSampleCollectionState"
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
        function obj = TissueSampleCollectionState()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end