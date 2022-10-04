classdef ContentType < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/ContentType"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'name'}
    end

    properties
        % Enter one or several file extensions associated with this content type.
        fileExtension (1,:) string

        % Enter a description of the content type specification. May be left blank if a public specification can be linked in 'specification'.
        description (1,1) string

        % Enter the iternationalized resource identifier (IRI) of the official registered media type (e.g. on IANA.org) matching this content type.
        relatedMediaType (1,1) string

        % Enter the name (iana-inspired convention) of this content type.
        name (1,1) string

        % Enter the iternationalized resource identifier (IRI) of the official specification of this content type. Leave blank and use 'description' to provide some specification if an official specification is not available.
        specification (1,1) string

        % Enter one or several synonyms of this content type.
        synonym (1,:) string
    end

    methods
        function obj = ContentType()
        end
    end

end