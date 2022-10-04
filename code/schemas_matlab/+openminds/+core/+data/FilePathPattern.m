classdef FilePathPattern < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/FilePathPattern"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'groupingType', 'regex'}
    end

    properties
        % Add the type of grouping that is defined by the given file path pattern.
        groupingType (1,1) openminds.controlledTerms.FileBundleGrouping

        % Enter the regular expression that defines this file path pattern.
        regex (1,1) string
    end

    methods
        function obj = FilePathPattern()
        end
    end

end