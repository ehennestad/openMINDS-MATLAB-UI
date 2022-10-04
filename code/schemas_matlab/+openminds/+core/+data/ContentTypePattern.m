classdef ContentTypePattern < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/ContentTypePattern"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'contentType', 'regex'}
    end

    properties
        % Enter the content type that can be defined by the given regular expression for file names/extentions.
        contentType (1,1) openminds.core.ContentType

        % Enter a lookup label for this content type pattern.
        lookupLabel (1,1) string

        % Enter a regular expression for the file names/extensions that defines the give content type.
        regex (1,1) string
    end

    methods
        function obj = ContentTypePattern()
        end
    end

end