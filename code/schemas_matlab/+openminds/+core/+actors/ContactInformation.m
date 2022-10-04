classdef ContactInformation < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/ContactInformation"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'email'}
    end

    properties
        % Enter the email address of this person.
        email (1,1) string
    end

    methods
        function obj = ContactInformation()
        end
    end

end