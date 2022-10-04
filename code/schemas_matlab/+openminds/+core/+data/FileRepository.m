classdef FileRepository < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/FileRepository"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'hostedBy', 'IRI', 'name'}
    end

    properties
        % Add all content type patterns that would identify matching content types for files within this file repository.
        contentTypePattern (1,:) openminds.core.ContentTypePattern

        % If file instances and bundles within the repository are organized and formatted according to a formal data structure use the appropriate contentType. Leave blank otherwise.
        format (1,1) openminds.core.ContentType

        % Add the hash that was generated for this file repository.
        hash (1,1) openminds.core.Hash

        % Add the host of this file repository.
        hostedBy (1,1) openminds.core.Organization

        % Enter the internationalized resource identifier (IRI) of this file repository.
        IRI (1,1) string

        % Enter the name of this file repository.
        name (1,1) string

        % Add the type of this file repository.
        repositoryType (1,1) openminds.controlledTerms.FileRepositoryType

        % Enter the storage size this file repository allocates.
        storageSize (1,1) openminds.core.QuantitativeValue

        % Add a file repository structure which identifies the file path patterns used in this file repository.
        structurePattern (1,1) openminds.core.FileRepositoryStructure
    end

    methods
        function obj = FileRepository()
        end
    end

end