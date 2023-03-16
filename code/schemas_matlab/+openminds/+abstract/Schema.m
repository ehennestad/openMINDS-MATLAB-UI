classdef Schema < handle & StructAdapter & matlab.mixin.CustomDisplay & uiw.mixin.AssignPVPairs %& ...
        %matlab.mixin.Heterogeneous & nansen.metadata.tablevar.mixin.HasTableColumnFormatter
    %& nansen.metadata.abstract.TableVariable 

% Todo:
%   [ ] Validate schema. I.e are all required variables filled out
%   [ ] Translate schema into a json?
%   [ ] Do some classes have to inherit from a mixin.Heterogeneous class?
%   [ ] Should controlled term instances be coded as enumeration classes?
%   [ ] Distinguish embedded from linked types.

    properties (Constant, Hidden) % Implement abstract property from nansen.metadata.abstract.TableVariable
        IS_EDITABLE = true;
        DEFAULT_VALUE = 'Undefined'
    end
    properties (Constant, Hidden)
        TableColumnFormatter = om.SchemaTableColumnFormatter
    end

    properties (Constant, Hidden)
        VOCAB = "https://openminds.ebrains.eu/vocab/"
    end

    properties (SetAccess = immutable, Hidden)
        id char = ''
    end

    properties (Dependent, Transient, Hidden)
        DisplayString
    end

    properties (Abstract, Constant, Hidden)
        X_TYPE (1,1) string
    end

    properties (Abstract, SetAccess = immutable)
        X_CATEGORIES
    end

    properties (Access = private)
        Required_
    end

    properties (Access = protected)
        Required
    end

    methods % Constructor
        
        function obj = Schema()
            if ~isa(obj, 'openminds.abstract.Instance')
                obj.id = om.strutil.getuuid;
            end
        end
        
    end

    methods (Access = public)
        
    end

    methods
        function displayLabel = get.DisplayString(obj)
            if isprop(obj, 'lookupLabel')
                displayLabel = obj.lookupLabel;
            else
                schemaShortName = obj.getSchemaShortName(class(obj));
                displayLabel = sprintf("%s-%s", schemaShortName, obj.id(1:8));
            end
        end

        function values = getSuperClassRequiredProperties(obj)
            values = obj.getAllSuperClassRequiredProperties(class(obj));
        end
    end

    methods (Sealed, Hidden) % Overrides subsref

% % %         function varargout = subsasgn(obj, s, value)
% % %         %subsasgn Override subsasgn to save preferences when they change
% % % 
% % %             numOutputs = nargout;
% % %             varargout = cell(1, numOutputs);
% % %             
% % %             isPropertyAssigned = strcmp(s(1).type, '.') && ...
% % %                 any( strcmp(properties(obj), s(1).subs) );
% % %             
% % %             if isPropertyAssigned && isa(obj.(s(1).subs), 'openminds.controlledterms.ControlledTerm')
% % %                 
% % %                 disp('a')
% % % 
% % %             end
% % % 
% % %             % Use the builtin subsref with appropriate number of outputs
% % %             if numOutputs > 0
% % %                 [varargout{:}] = builtin('subsasgn', obj, s, value);
% % %             else
% % %                 builtin('subsasgn', obj, s)
% % %             end
% % %         end
    end

    methods (Access = protected)
        function str = getHeader(obj)
            str = getHeader@matlab.mixin.CustomDisplay(obj);
            str = replace(str, 'with properties:', sprintf('(%s) with properties:', obj(1).X_TYPE));
            str = [newline, str];
        end

        function str = getFooter(obj)
            str = '';

            if isempty(obj)
                return
            end

            if ~isempty(obj(1).Required)
                str = sprintf('  Required Properties: <strong>%s</strong>', strjoin(obj(1).Required, ', '));
            end
        end
    end

    methods (Static, Access = private)
        
        function values = getAllSuperClassRequiredProperties(className)

            import openminds.abstract.Schema.getAllSuperClassRequiredProperties

            % recursively get required props from superclasses
            mc = meta.class.fromName(className);
            superClassList = mc.SuperclassList;

            % If there are more than one subclass, we reached the
            % abstract Schema class and can safely return
            % Todo: need to double check this
            if numel(superClassList) > 1 || isempty(superClassList)
                values = {}; return
            end

            isReq = strcmp( {superClassList.PropertyList.Name}, 'Required_' );
            if any(isReq)
                if superClassList.PropertyList(isReq).HasDefault
                    values = superClassList.PropertyList(isReq).DefaultValue;
                else
                    values = {};
                end
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

    methods (Static, Access = protected, Hidden)
        
        function shortSchemaName = getSchemaShortName(fullSchemaName)
        %getSchemaShortName Get short schema name from full schema name
        % 
        %   shortSchemaName = getSchemaShortName(fullSchemaName)
        %
        %   Example:
        %   fullSchemaName = 'openminds.core.research.Subject';
        %   shortSchemaName = om.MetadataSet.getSchemaShortName(fullSchemaName)
        %   shortSchemaName =
        % 
        %     'Subject'

            expression = '(?<=\.)\w*$'; % Get every word after a . at the end of a string
            shortSchemaName = regexp(fullSchemaName, expression, 'match', 'once');
            if isempty(shortSchemaName)
                shortSchemaName = fullSchemaName;
            end
        end
    end

end