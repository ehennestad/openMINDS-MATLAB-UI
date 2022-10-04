classdef Copyright < openminds.abstract.OpenMINDSSchema

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/Copyright"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'holder', 'year'}
    end

    properties
        % Add one or several persons or organisations that hold the copyright.
        holder (1,:) {core.category.LegalPerson}

        % Enter the year during which the copyright was first asserted.
        year (1,1) string
    end

    methods
        function obj = Copyright()
        end
    end

end