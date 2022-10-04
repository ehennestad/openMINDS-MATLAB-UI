classdef Preferences < matlab.mixin.CustomDisplay
%Preferences Preferences for the openMINDS matlab toolbox

    properties (Constant, Hidden)
        GroupName = 'OpenMINDS' % Group name in the preferences
    end
    
    properties (Constant, Access = private) % Default values for preferences 
        SourceDirectory      = ''
        MSchemaDirectory     = ''
        %UseCacheOnCloud     = false
        %CachingMode         = 'web'        
    end

    properties (Constant, Access = private, Transient) % Validation of preferences.
        SourceDirectory_     = struct('classes', {{'char', 'string'}}, 'attributes', {{}}, 'values', {{}})
        MSchemaDirectory_     = struct('classes', {{'char', 'string'}}, 'attributes', {{}}, 'values', {{}})
        %UseCacheOnCloud_    = struct('classes', {'logical'},          'attributes', {{}}, 'values', {{}})
        %CachingMode_        = struct('classes', {{'char', 'string'}}, 'attributes', {{}}, 'values', {{'web', 's3'}})
    end

    methods (Access = protected)
        function str = getHeader(obj)
            str = getHeader@matlab.mixin.CustomDisplay(obj);
            str = replace(str, 'Preferences', 'om.Preferences');
            str = replace(str, 'with no properties.', 'has the following items:');
            %str = sprintf('The following preferences are available for %s:\n', om.Preferences.GroupName);
        end

        function str = getFooter(~)
            str = 'Use the methods get(value) or set(name, value) to access or modify preferences';
        end

        function groups = getPropertyGroups(obj)
            if ispref(obj.GroupName)
                propListing = getpref(obj.GroupName);
            else
                obj.initializePreferences(obj.GroupName)
                propListing = getpref(obj.GroupName);
            end
            groups = matlab.mixin.util.PropertyGroup(propListing);
        end
        
    end

    methods (Static)

        function set(preferenceName, value)
            
            validationStruct = om.Preferences.([preferenceName '_']);

            validateattributes(value, validationStruct.classes, validationStruct.attributes);

            if ~isempty(validationStruct.values)
                
                switch class( validationStruct.values{1} )
                    case {'char', 'string'}
                        value = validatestring(value, validationStruct.values);
                    otherwise 
                        error('Not implemented yet')
                end
            end

            setpref(om.Preferences.GroupName, preferenceName, value)
        end

        function value = get(preferenceName)
            if ispref(om.Preferences.GroupName, preferenceName)
                value = getpref(om.Preferences.GroupName, preferenceName);
            else
                value = om.Preferences.(preferenceName);
            end
        end

        function tf = isequal(preferenceName, promptValue)
            
            prefValue = om.Preferences.get(preferenceName);

            switch class(prefValue)
                case 'char'
                    tf = strcmp(prefValue, promptValue);
                    
                otherwise
                    tf = isequal(prefValue, promptValue);
            end
        end

    end

    methods (Static, Access = private)
        
        function initializePreferences(groupName)
            
            mc = ?om.Preferences;
            propKeep = [mc.PropertyList.Constant] & ~[mc.PropertyList.Transient] & ~[mc.PropertyList.Hidden];
            
            propIdx = find(propKeep);

            for i = propIdx
                setpref(groupName, mc.PropertyList(i).Name, mc.PropertyList(i).DefaultValue)
            end
            
        end
    end

end