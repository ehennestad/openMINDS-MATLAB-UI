classdef File < openminds.abstract.OpenMINDSSchema & core.category.FileOrigin

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/File"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {'fileOrigin'}
    end

    properties (SetAccess = immutable)
        Required = {'IRI', 'isPartOf', 'name'}
    end

    properties
        % Enter a short content description for this file instance.
        content (1,1) string

        % Add all entities that played a role in the production of this single file.
        descendedFrom (1,:) {core.category.FileOrigin}

        % Add the over all repository to which this single file belongs.
        fileRepository (1,1) openminds.core.FileRepository

        % Add the content type of this file instance.
        format (1,1) openminds.core.ContentType

        % Add the hash that was generated for this file instance.
        hash (1,1) openminds.core.Hash

        % Enter the internationalized resource identifier of this single file.
        IRI (1,1) string

        % Add one or several bundles in which this single file can be grouped.
        isPartOf (1,:) openminds.core.FileBundle

        % Enter the name of this single file.
        name (1,1) string

        % Add a special usage role for this single file.
        specialUsageRole (1,1) openminds.controlledTerms.FileUsageRole

        % Enter the storage size this file instance allocates.
        storageSize (1,1) openminds.core.QuantitativeValue
    end

    methods
        function obj = File()
        end
    end

end