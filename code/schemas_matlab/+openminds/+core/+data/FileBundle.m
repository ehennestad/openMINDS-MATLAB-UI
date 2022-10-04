classdef FileBundle < openminds.abstract.OpenMINDSSchema & core.category.FileOrigin

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/FileBundle"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {'fileOrigin'}
    end

    properties (SetAccess = immutable)
        Required = {'isPartOf', 'name'}
    end

    properties
        % Enter a short content description for this file bundle.
        content (1,1) string

        % Add all entities that played a role in the production of this file bundle (must be true for all grouped files).
        descendedFrom (1,:) {core.category.FileOrigin}

        % If file instances within this bundle are organized and formatted according to a formal data structure use the appropriate contentType. Leave blank otherwise.
        format (1,1) openminds.core.ContentType

        % Enter a regular expression (syntax: ECMA 262) which is valid for all filenames of the file instances that should be grouped into this file bundle.
        patternOfFilenames (1,1) string

        % Add the concept which was used to group file instances into this file bundle.
        groupedBy (1,1) openminds.controlledTerms.FileBundleGrouping

        % Add the hash that was generated for this file bundle.
        hash (1,1) openminds.core.Hash

        % Add the file bundle or file repository this file bundle is a part of.
        isPartOf (1,1) {openminds.core.FileBundle, openminds.core.FileRepository}

        % Enter the name of this file bundle.
        name (1,1) string

        % Enter the storage size this file bundle allocates.
        storageSize (1,1) openminds.core.QuantitativeValue
    end

    methods
        function obj = FileBundle()
        end
    end

end