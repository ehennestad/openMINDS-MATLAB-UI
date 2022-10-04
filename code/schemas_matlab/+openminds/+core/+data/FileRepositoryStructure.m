classdef FileRepositoryStructure < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/FileRepositoryStructure"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'filePathPattern'}
    end

    properties
        % Add all file path patterns that define this file repository structure.
        filePathPattern (1,:) openminds.core.FilePathPattern

        % Enter a lookup label for this file repository structure.
        lookupLabel (1,1) string
    end

    methods
        function obj = FileRepositoryStructure()
        end
    end

end