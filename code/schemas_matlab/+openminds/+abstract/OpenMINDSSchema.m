classdef OpenMINDSSchema < handle & matlab.mixin.CustomDisplay

% Todo:
%   [ ] Validate schema. I.e are all required variables filled out
%   [ ] Translate schema into a json?
%   [ ] Do some classes have to inherit from a mixin.Heterogeneous class?
%   [ ] Should controlled term instances be coded as enumeration classes?
%   [ ] Distinguish embedded from linked types.

    properties (Abstract, Constant, Hidden)
        X_TYPE
    end

    properties (Abstract, SetAccess = immutable)
        X_CATEGORIES
    end

    properties (Access = private)
        Required
    end


    methods
        function values = getSuperClassRequiredProperties(obj)
            values = obj.getAllSuperClassRequiredProperties(class(obj));
        end
    end

    methods (Access = protected)
        function str = getHeader(obj)
            str = getHeader@matlab.mixin.CustomDisplay(obj);
            str = replace(str, 'with properties:', sprintf('(%s) with properties:', obj.X_TYPE));
        end
    end

    methods (Static, Access = private)
        
        function values = getAllSuperClassRequiredProperties(className)

            import openminds.abstract.OpenMINDSSchema.getAllSuperClassRequiredProperties

            % recursively get required props from superclasses
            mc = meta.class.fromName(className);
            superClassList = mc.SuperclassList;

            % If there are more than one subclass, we reached the
            % OpenMINDSSchema class and can safely return
            if numel(superClassList) > 1 
                values = {}; return
            end

            isReq = strcmp( {superClassList.PropertyList.Name}, 'Required' );
            if any(isReq)
                values = superClassList.PropertyList(isReq).DefaultValue;
            else
                values = {};
            end

            if ~isempty( superClassList.SuperclassList)
                greatSuperclassName = superClassList.SuperclassList.Name;
                values = [values, ...
                    getAllSuperClassRequiredProperties(greatSuperclassName)];
            end
        end
        
    end

end