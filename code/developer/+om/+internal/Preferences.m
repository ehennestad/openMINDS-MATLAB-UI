classdef Preferences < matlab.mixin.CustomDisplay & handle

    properties (Constant, Access = private)
        PreferenceGroupName = 'openMINDS'
    end

    properties
        % Source directory for schemas
        SourceDirectory     (1,1) string = ""
        
        % Source directory for matlab schemas
        MSchemaDirectory    (1,1) string = ""
    end

    properties (Constant, Access = private)
        Filename = fullfile(prefdir, 'OpenMindsPreferences.mat')
    end
    
    methods
        function changeSourceDirectory(obj)
            newFolder = uigetdir();
            if isequal(newFolder, 0)
                disp('Operation canceled.')
                return
            else
                obj.SourceDirectory = newFolder;
                msg = sprintf('Source folder changed to: %s', obj.SourceDirectory);
                fprintf('%s\n', msg)
                obj.save()
                %bot.internal.Logger.inform(msg, 'Updated Preferences')
            end
        end
        
        function changeMSchemaDirectory(obj)
            newFolder = uigetdir();
            if isequal(newFolder, 0)
                disp('Operation canceled.')
                return
            else
                obj.MSchemaDirectory = newFolder;
                msg = sprintf('Source folder changed to: %s', obj.MSchemaDirectory);
                fprintf('%s\n', msg)
                obj.save()
                %bot.internal.Logger.inform(msg, 'Updated Preferences')
            end
        end
    end

    methods (Access = private)
        function obj = Preferences()
            if isfile(obj.Filename)
                S = load(obj.Filename);
                obj = S.obj;
            end
        end

        function propertyNames = getCurrentPreferenceGroup(obj)
            propertyNames = properties(obj);
        end

        function save(obj)
            disp('saved')
            save(obj.Filename, 'obj');
        end

        function load(obj)

        end
    end

    methods (Sealed, Hidden)

        function varargout = subsasgn(obj, s, value)
            
            numOutputs = nargout;
            varargout = cell(1, numOutputs);
            
            isPropertyAssigned = strcmp(s(1).type, '.') && ...
                any( strcmp(properties(obj), s(1).subs) );
            
            % If we got this far, use the builtin subsref
            if numOutputs > 0
                [varargout{:}] = builtin('subsasgn', obj, s, value);
            else
                builtin('subsasgn', obj, s)
            end

            if isPropertyAssigned
                obj.save()
            end
        end
        

        function n = numArgumentsFromSubscript(obj, s, indexingContext)
            n = builtin('numArgumentsFromSubscript', obj, s, indexingContext);
        end
    end

    methods (Access = protected)
        function str = getHeader(obj)
            className = class(obj);
            helpLink = sprintf('<a href="matlab:help %s" style="font-weight:bold">%s</a>', className, obj.PreferenceGroupName);
            str = sprintf('%s has the following preferences:\n', helpLink);
        end

        function groups = getPropertyGroups(obj)
            propNames = obj.getCurrentPreferenceGroup();
            
            s = struct();
            for i = 1:numel(propNames)
                s.(propNames{i}) = obj.(propNames{i});
            end

            groups = matlab.mixin.util.PropertyGroup(s);
        end
        
    end

    methods (Static, Hidden)

        function obj = getSingleton()

            persistent singletonObject

            if isempty(singletonObject)
                singletonObject = om.internal.Preferences();
            end
            
            obj = singletonObject;
        end
    end

end
