classdef ServiceLink < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/ServiceLink"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'dataLocation', 'openDataIn', 'service'}
    end

    properties
        % Add the file or file bundle with the data that are linked to the specified service.
        dataLocation (1,1) {openminds.core.File, openminds.core.FileBundle}

        % Enter a name that should be used as preferred display label for this service link.
        name (1,1) string

        % Add the uniform resource locator (URL) to open the linked data in the specified service.
        openDataIn (1,1) openminds.core.URL

        % Add the service in which the specified data can be opened.
        service (1,1) openminds.controlledTerms.Service
    end

    methods
        function obj = ServiceLink()
        end
    end

end