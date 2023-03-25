classdef Schema < handle & StructAdapter & matlab.mixin.CustomDisplay & om.external.uiw.mixin.AssignPVPairs & matlab.mixin.CustomCompactDisplayProvider %& ...
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
        TableColumnFormatter = om.SchemaTableColumnFormatter % Todo: remove.
    end

    properties (Constant, Hidden) % Move to instance/serializer
        VOCAB = "https://openminds.ebrains.eu/vocab/"
    end

    properties (SetAccess = immutable, Hidden)
        id char = '' % Todo: Move to instance
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

% %     properties (Abstract, Constant)
% %         LINKED_PROPERTIES struct
% %         EMBEDDED_PROPERTIES struct
% %     end

    properties (Access = private) % TODO: Join...
        Required_
    end

    properties (Access = protected)
        Required
    end

    methods % Constructor
        
        function obj = Schema()
            if ~isa(obj, 'openminds.abstract.Instance')
                obj.id = sprintf('%s-%s', obj.getSchemaShortName(class(obj)), om.strutil.getuuid);
            end
        end
        
    end

    methods (Access = public)
        
        function tf = isPropertyWithLinkedType(obj, propertyName)
            propertyNamesWithLinkedType = fieldnames(obj.LINKED_PROPERTIES);
            tf = any( strcmp(propertyNamesWithLinkedType, propertyName) );
        end

        function linkedTypesForProperty = getLinkedTypesForProperty(obj, propertyName)
            
            if obj.isPropertyWithLinkedType(propertyName)
                linkedTypesForProperty = obj.LINKED_PROPERTIES.(propertyName);
            else
                error('Property %s does not have linked types', propertyName);
            end
        end

        function tf = isLinkedTypeOfProperty(obj, type)
            
            tf = false;

            propertyNames = fieldnames( obj.LINKED_PROPERTIES );

            for i = 1:numel(propertyNames)
                types = obj.LINKED_PROPERTIES.(propertyNames{i});

                for j = 1:numel(types)
                    thisType = types{j};

                    tf = strcmp(thisType, type);
                    if tf; return; end

                    thisTypeSplit = strsplit(thisType, '/');
                    tf = strcmp(thisTypeSplit{end}, type);
                    if tf; return; end
                end
            end
        end

        function propertyName = linkedTypeOfProperty(obj, type)
            propertyName = obj.linkedTypeOfPropertyStatic(type, obj.LINKED_PROPERTIES);
        end
        
    end

    methods
        function displayLabel = get.DisplayString(obj)
            if isa(obj, 'openminds.controlledterms.ControlledTerm')
                displayLabel = sprintf('%s', char(obj));
                return
            end

            displayLabel = obj.getDisplayLabel();

            if isempty(displayLabel)
                schemaShortName = obj.getSchemaShortName(class(obj));
                displayLabel = sprintf("%s-%s", schemaShortName, obj.id(1:8));
            end
        end

        function values = getSuperClassRequiredProperties(obj)
            values = obj.getAllSuperClassRequiredProperties(class(obj));
        end
    end

    methods % % CustomCompactDisplayProvider Method implementation
        
        function rep = compactRepresentationForSingleLine(obj, displayConfiguration, width)
            
            if nargin < 2
                displayConfiguration = matlab.display.DisplayConfiguration();
            end

            numObjects = numel(obj);
            
            schemaName = obj.getSchemaShortName(class(obj));

            if isa(obj, 'openminds.controlledterms.ControlledTerm')
                annotation = 'Controlled Term';
            else
                annotation = schemaName;

                annotation = getSchemaDocLink(  class(obj) );
                %helpLink = sprintf('<a href="matlab:helpPopup %s" style="font-weight:bold">%s</a>', class(obj), schemaName);
                %annotation = helpLink;
            end

            if numObjects == 0
                str = 'None';
                %str = sprintf("Empty %s", schemaName);
                rep = matlab.display.PlainTextRepresentation(obj, str, displayConfiguration, 'Annotation', annotation);
                %rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', string(str));

            elseif numObjects == 1
                rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', obj.DisplayString, 'Annotation', annotation);
            else
                rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', arrayfun(@(o) o.DisplayString, obj, 'UniformOutput', false), 'Annotation', annotation);

                %rep = compactRepresentationForSingleLine@matlab.mixin.CustomCompactDisplayProvider(obj, displayConfiguration, width);
            end
        end

        function rep = compactRepresentationForColumn(obj, displayConfiguration, default)
            
            %Note: Input will be an array with one object per row in the
            % column to represent. Output needs to take this into account.
            
            if nargin < 2
                displayConfiguration = matlab.display.DisplayConfiguration();
            end
            
            % Todo: Do this per row....
            numObjects = numel(obj);

            numRows = size(obj, 1);

            schemaName = obj.getSchemaShortName(class(obj));

            if numObjects == 0
                % str = 'None';
                % Todo: Make plural labels.
                str = sprintf('No %s available', schemaName);
                rep = matlab.display.PlainTextRepresentation(obj, repmat({str}, numRows, 1), displayConfiguration);
            elseif numObjects >= 1 
                %str = obj.DisplayString;
                rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', arrayfun(@(i) obj(i).DisplayString, [1:numRows]', 'uni', 0) );

            elseif numObjects > 1
                %rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', obj.DisplayString );
                rep = compactRepresentationForColumn@matlab.mixin.CustomCompactDisplayProvider(obj, displayConfiguration, default);
            end
            
            % Fit all array elements in the available space, or else use
            % the array dimensions and class name
            % rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', str );
        end

    end

    

    methods (Hidden) % Overrides subsref

        function obj = subsasgn(obj, subs, value)
            
            if isequal(obj, [])
                % As far as I understand, this only occurs during property
                % initialization of properties with a defined class.
                obj = eval(sprintf('%s.empty', class(value)));
            end

            if obj.isSubsForLinkedPropertyValue(subs)
                propName = subs(1).subs;
                className = class(obj.(propName));
            
                % Get the actual instance from a linkset subclass.
                if contains(className, 'openminds.linkset')
                    try
                        classFcn = str2func(className);
                        value = classFcn(value);
                    catch ME
                        msg = sprintf("Error getting instance of linked type '%s' of class '%s'. ", propName, class(obj));
                        errorStruct.identifier = 'LinkedProperty:CouldNotRetrieveInstance';
                        errorStruct.message = msg + ME.message;
                        errorStruct.stack = struct('file', '', 'name', class(obj), 'line', 0);
                        error(errorStruct)
                    end
                end

                try
                    obj = builtin('subsasgn', obj, subs, value);
                    %obj.notify('LinkedPropertyChanged', event.EventData)
                catch ME
                    msg = sprintf("Error setting property '%s' of class '%s'. ", propName, class(obj));
                    errorStruct.identifier = 'LinkedProperty:InvalidType';
                    errorStruct.message = msg + ME.message;
                    errorStruct.stack = struct('file', '', 'name', class(obj), 'line', 0);
                    error(errorStruct)
                end
            else
                
                obj = builtin('subsasgn', obj, subs, value);
            end

            if ~nargout
                clear obj
            end
        end


        function varargout = subsref(obj, subs)
            
            numOutputs = nargout;
            varargout = cell(1, numOutputs);
            

            if obj(1).isSubsForLinkedPropertyValue(subs)
                  
                linkedTypeValues = builtin('subsref', obj, subs(1));

                if isa(linkedTypeValues, 'openminds.abstract.LinkedCategory')
                    values = {linkedTypeValues.Instance};
                else
                    values = linkedTypeValues;
                end
                
                if numel(subs) > 1
                    if strcmp( subs(2).type, '()' )
                        subs(2).type = '{}';
                    end

                    if numOutputs > 0
                        [varargout{:}] = builtin('subsref', values, subs(2:end));
                    else
                        builtin('subsref', values, subs(2:end))
                    end
                else
                    if numOutputs > 0
                        [varargout{:}] = values;
                    else
                        varargout = values;
                    end
                end
            else
                if numOutputs > 0
                    [varargout{:}] = builtin('subsref', obj, subs);
                else
                    builtin('subsref', obj, subs)
                end
            end
        end

        function n = numArgumentsFromSubscript(obj, s, indexingContext)
            if obj(1).isSubsForLinkedPropertyValue(s) && numel(s) > 1
                linkedTypeValues = builtin('subsref', obj, s(1));
                values = {linkedTypeValues.Instance};

                if strcmp( s(2).type, '()' )
                    s(2).type = '{}';
                end
                n = builtin('numArgumentsFromSubscript', values, s(2:end), indexingContext);
            else
                n = builtin('numArgumentsFromSubscript', obj, s, indexingContext);
            end
        end

        function tf = isSubsForLinkedPropertyValue(obj, subs)
        % Return true if subs represent dot-indexing on a linked property
            tf = strcmp( subs(1).type, '.' ) && isfield(obj.LINKED_PROPERTIES, subs(1).subs);
        end

        function getLinkedPropertyInstance(obj, subs)

        end

    end

    methods (Access = protected)

        function str = getDisplayLabel(obj)
            disp('here')

            str = '';
        end
    end

    methods (Access = protected)
        function str = getHeader(obj)
            
            if numel(obj)==0
                openMindsType = eval( [class(obj) '.X_TYPE'] );
            else
                openMindsType = obj(1).X_TYPE;
            end

            docLinkStr = getSchemaDocLink(class(obj));

            str = sprintf('  %s (%s) with properties:\n', docLinkStr, openMindsType);
            %str = [newline, str];
        end

        function str = getFooter(obj)
            str = '';

            if isempty(obj)
                return
            end

            if ~isempty(obj(1).Required)
                str = sprintf('  Required Properties: <strong>%s</strong>', strjoin(obj(1).Required, ', '));
                str = om.strutil.strfold(str, 100);
                str = strjoin(str, '\n    ');
                str = sprintf('  %s', str);
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

    methods (Static, Access = public, Hidden)
        
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

    methods (Static)
        
        function propertyName = linkedTypeOfPropertyStatic(type, linkedTypeProperties)
            
            propertyNamesWithLinkedType = fieldnames( linkedTypeProperties );

            for i = 1:numel(propertyNamesWithLinkedType)
                types = linkedTypeProperties.(propertyNamesWithLinkedType{i});

                for j = 1:numel(types)
                    thisType = types{j};

                    tf = strcmp(thisType, type);
                    if tf
                        propertyName = propertyNamesWithLinkedType{i};
                        return
                    end

                    thisTypeSplit = strsplit(thisType, '/');
                    tf = strcmp(thisTypeSplit{end}, type);
                    if tf
                        propertyName = propertyNamesWithLinkedType{i};
                        return
                    end
                end
            end
        end
        
    end
end