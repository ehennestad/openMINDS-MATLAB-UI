classdef Schema < handle & StructAdapter & matlab.mixin.CustomDisplay & om.external.uiw.mixin.AssignPVPairs & matlab.mixin.CustomCompactDisplayProvider %& ...
        %matlab.mixin.Heterogeneous 
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

    properties (Constant, Hidden) % Move to instance/serializer
        VOCAB = "https://openminds.ebrains.eu/vocab/"
    end

    properties (SetAccess = protected, Hidden)
        id char = '' % Todo: Move to instance
        IsConstructed = false;
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

    events
        InstanceChanged
        PropertyWithLinkedInstanceChanged
    end

    methods % Constructor
        
        function obj = Schema()
            if ~isa(obj, 'openminds.abstract.Instance')
                obj.id = sprintf('%s-%s', obj.getSchemaShortName(class(obj)), om.strutil.getuuid);
            end
            obj.IsConstructed = true;
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
        function str = char(obj)
            str = obj.getDisplayLabel();
        end

        function displayLabel = get.DisplayString(obj)
            if isa(obj, 'openminds.controlledterms.ControlledTerm')
                %displayLabel = sprintf('%s', char(obj));
                displayLabel = sprintf('%s', obj.name);
                return
            end

            displayLabel = obj.getDisplayLabel();

            if isempty(displayLabel)
                schemaShortName = obj.getSchemaShortName(class(obj));

                % Use regexp to extract to schema name and the first part
                % of the uuid
                str = regexp(obj.id, '^\w*-\w*(?=-)', 'match', 'once');
                displayLabel = sprintf("%s", str);
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

    methods (Hidden) % Overrides subsref & subsasgn

        function obj = subsasgn(obj, subs, value)
            
            import om.instance.event.PropertyValueChangedEventData

            if isequal(obj, [])
                % As far as I understand, this only occurs during property
                % initialization of properties with a defined class, in
                % which case the obj has to be assigned with an instance of
                % the correct class.
                obj = eval(sprintf('%s.empty', class(value)));
            end

            if obj.isSubsForLinkedPropertyValue(subs) || obj.isSubsForEmbeddedPropertyValue(subs)
                propName = subs(1).subs;

                if numel(subs) == 1
                    propName = subs(1).subs;
                    className = class(obj.(propName));
                
                    % Get the actual instance from a linkset subclass.
                    if contains(className, 'openminds.linkedcategory')
                        try
                            % Place the openMINDS instance object in a linkset
                            % wrapper class
                            classFcn = str2func(className);
                            value = classFcn(value);
                        catch MECause
                            msg = sprintf("Error setting instance of linked type '%s' of class '%s'. ", propName, class(obj));
                            errorStruct.identifier = 'LinkedProperty:CouldNotRetrieveInstance';
                            errorStruct.message = msg + MECause.message;
                            errorStruct.stack = struct('file', '', 'name', class(obj), 'line', 0);
                            error(errorStruct)
                        end
                    end
                elseif numel(subs) > 1 
                    % Pass for now. 
                    % This case should be handled below? What if multiple
                    % instances should be placed in the linkset wrapper?
                end

                try
                    if numel(subs) == 1
                        % Assigning a linked property
                        oldValue = obj.subsref(subs);

                        obj = builtin('subsasgn', obj, subs, value);

                        % Assign new value and trigger event
                        evtData = PropertyValueChangedEventData(value, oldValue, true); % true for linked prop
                        obj.notify('PropertyWithLinkedInstanceChanged', evtData)

                    elseif numel(subs) > 1 && strcmp(subs(2).type, '.')
                        % Modifying a linked property
                        
                        linkedObj = obj.subsref(subs(1));
                        if isa(linkedObj, 'cell')
                            className = class(obj.(subs(1).subs));
                            if contains(className, 'openminds.linkedcategory')
                                % Todo: Check if instances in cell array
                                % are of different types.
                                error('Can not use indexing assignment for instances of different types')
                            else
                                error('Unexpected error occured, please report')
                            end
                        end
                        oldValue = linkedObj.subsref(subs(2:end));

                        % Assign new value and trigger event
                        linkedObj.subsasgn(subs(2:end), value);
                        evtData = PropertyValueChangedEventData(value, oldValue, true); % true for linked prop
                        obj.notify('PropertyWithLinkedInstanceChanged', evtData)

                    elseif numel(subs) > 1 && strcmp(subs(2).type, '()')
                        try
                            linkedObj = obj.subsref(subs(1:2));

                        catch MECause

                            switch MECause.identifier
                                case 'MATLAB:badsubscript'
                                    % Bad subscript might occur when
                                    % someone tries to assign a value to a
                                    % part of the array that does not exist
                                    % yet. Use builtin subasgn to deal with
                                    % this... This should be improved, as
                                    % empty values default to empty double,
                                    % but should be empty object of correct
                                    % instance type.
                                    try
                                        obj = builtin('subsasgn', obj, subs, value);
                                    catch ME
                                        errorStruct.identifier = ME.identifier;
                                        errorStruct.message = ME.message;
                                        errorStruct.stack = struct('file', '', 'name', class(obj), 'line', 0);
                                        error(errorStruct)
                                    end


                                    %obj.subsasgn(subs, value);
                                otherwise
                                    ME = MException('OPENMINDS_MATLAB:UnhandledIndexAssignment', ...
                                        'Unhandled index assignment, please report');
                                    ME.addCause(MECause)
                                    throw(ME)
                            end
                        end

                    else
                        error('Unhandled indexing assignment')
                    end
                catch ME
                    msg = sprintf("Error setting property '%s' of class '%s'. ", propName, class(obj));
                    errorStruct.identifier = 'LinkedProperty:InvalidType';
                    errorStruct.message = msg + ME.message;
                    errorStruct.stack = struct('file', '', 'name', class(obj), 'line', 0);
                    error(errorStruct)
                end
                
                fprintf('set linked property of %s\n', class(obj))
            else
                if ~isempty(obj)
                    oldValue = builtin('subsref', obj, subs);
                else
                    oldValue = [];
                end
                
                obj = builtin('subsasgn', obj, subs, value);

                if numel(obj) >= 1
                    if obj.isSubsForPublicPropertyValue(subs)
                        evtData = PropertyValueChangedEventData(value, oldValue, false); % false for unlinked prop
                        obj.notify('InstanceChanged', evtData)
                        fprintf('Set unlinked property of %s\n', class(obj))
                    end
                end

            end

            if ~nargout
                clear obj
            end
        end

        function varargout = subsref(obj, subs)
            
            numOutputs = nargout;
            varargout = cell(1, numOutputs);
            

            if obj.isSubsForLinkedPropertyValue(subs) || obj.isSubsForEmbeddedPropertyValue(subs)
                  
                linkedTypeValues = builtin('subsref', obj, subs(1));

                if isa(linkedTypeValues, 'openminds.abstract.LinkedCategory')
                    values = {linkedTypeValues.Instance};
                    
                    instanceType = cellfun(@(c) class(c), values, 'uni', false);
                    if numel( unique(instanceType) ) == 1
                        values = [values{:}];
                    end

                else
                    values = linkedTypeValues;
                end
                
                if numel(subs) > 1
                    if strcmp( subs(2).type, '()' ) && iscell(values)
                        subs(2).type = '{}';
                    end

                    if numOutputs > 0
% % %                         if isequal(subs(2).type, '()') || isequal(subs(2).type, '{}')
% % %                             numInstances = numel(values);
% % %                             if ~ismember([subs(2).subs{:}], 1:numInstances)
% % %                                 [varargout{:}] = deal([]);
% % %                             else
% % %                                 [varargout{:}] = builtin('subsref', values, subs(2:end));
% % %                             end
% % %                         else

% % %                         end
                        if isa(values, 'openminds.abstract.Schema')
                            [varargout{:}] = values.subsref(subs(2:end));
                        else
                            [varargout{:}] = builtin('subsref', values, subs(2:end));
                        end
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
            if (obj(1).isSubsForLinkedPropertyValue(s) || obj(1).isSubsForEmbeddedPropertyValue(s)) && numel(s) > 1
                linkedTypeValues = builtin('subsref', obj, s(1));
                if isa(linkedTypeValues, 'openminds.abstract.LinkedCategory')
                    linkedTypeValues = {linkedTypeValues.Instance};
                end

                if strcmp( s(2).type, '()' )
                    s(2).type = '{}';
                end
                n = builtin('numArgumentsFromSubscript', linkedTypeValues, s(2:end), indexingContext);
            else
                n = builtin('numArgumentsFromSubscript', obj, s, indexingContext);
            end
        end

        function tf = isSubsForLinkedPropertyValue(obj, subs)
        % Return true if subs represent dot-indexing on a linked property
            
            if numel(obj)>=1
                tf = strcmp( subs(1).type, '.' ) && isfield(obj(1).LINKED_PROPERTIES, subs(1).subs);
            else
                linkedProps = eval( sprintf( '%s.LINKED_PROPERTIES', class(obj) ));
                tf = strcmp( subs(1).type, '.' ) && isfield(linkedProps, subs(1).subs);
            end
        end

        function tf = isSubsForEmbeddedPropertyValue(obj, subs)
        % Return true if subs represent dot-indexing on a linked property
            
            if numel(obj)>=1
                tf = strcmp( subs(1).type, '.' ) && isfield(obj(1).EMBEDDED_PROPERTIES, subs(1).subs);
            else
                embeddedProps = eval( sprintf( '%s.EMBEDDED_PROPERTIES', class(obj) ));
                tf = strcmp( subs(1).type, '.' ) && isfield(embeddedProps, subs(1).subs);
            end
        end

        function tf = isSubsForPublicPropertyValue(obj, subs)
        % Return true if subs represent dot-indexing on a public property
            
            tf = false;
    
            if strcmp( subs(1).type, '.' )
                propNames = properties(obj);
                tf = any( strcmp(subs(1).subs, propNames) );
            end
        end

        function getLinkedPropertyInstance(obj, subs)

        end

    end

    methods (Access = private) % Methods related to setting new values
        
        function assignLinkedInstance(obj)


        end

        function assignUnlinkedInstance(obj)


        end
    end

    methods (Access = protected)

        function str = getDisplayLabel(obj)
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

            if numel(obj) == 0
                docLinkStr = sprintf('Empty %s', docLinkStr);
            elseif numel(obj) > 1
                docLinkStr = sprintf('1x%d %s', numel(obj), docLinkStr);
            end

            str = sprintf('  %s (%s) with properties:\n', docLinkStr, openMindsType);
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
                str = sprintf('  %s\n', str);
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