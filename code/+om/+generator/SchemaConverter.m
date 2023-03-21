classdef SchemaConverter < ClassWriter
%SchemaConverter Translate openMINDS schemas to matlab classes    

    properties (Constant)
        DEBUG (1,1) matlab.lang.OnOffSwitchState = 'off'
    end
    
    properties (SetAccess = private)
        Schema              % Holds the openMINDS schema as a struct
    end

    properties (Access = private)
        SchemaName = ''             % i.e subjectGroup
        SchemaCategory = ''         % i.e research / data  % todo: rename to submodule???
        MetadataModel = ''          % i.e core / SANDS
    end 

    properties (Dependent)
        IsOfCategory
        SchemaClassName             % i.e SubjectGroup
    end

    properties (Access = private)
        SchemaClassFilePath % File path to the openMINDS source schema 
        IsControlledTerm = false
    end


    methods
        function obj = SchemaConverter(schemaFilepath, action)

            arguments
                schemaFilepath string % Filepath for en openMINDS schema
                action
            end
            
            % Assign filepath of openMINDS source schema
            obj.SchemaClassFilePath = schemaFilepath;
            
            obj.parseSchema()

            obj.assignOutputFile()

            if isfile(obj.Filepath) && strcmp(action, 'create')
                clear obj; return
            end

            obj.writeClassdef()
            
            obj.saveClassdef()
            
            clear obj
        end

    end

    methods

        function resolveSuperclasses(obj)

            % All schemas inherit from Schema.
            % obj.addSuperclass('openminds.abstract.Schema')

            % Todo: Determine if it extends controlled term: Todo:
            % deprecate
            hasMoreSuperclasses = isfield(obj.Schema, 'x_extends');
            
            if obj.IsControlledTerm
                obj.addSuperclass('openminds.controlledterms.ControlledTerm')
                obj.addSuperclass('openminds.abstract.Instance')
            else
                % All schemas inherit from Schema.
                obj.addSuperclass('openminds.abstract.Schema')
            end

            if hasMoreSuperclasses
                disp('has more superclasses, %s', obj.SchemaName)
            end
        end

        function update(obj)
            obj.writeClassdef()
            obj.updateSchemaClassFilePath()
            obj.saveClassdef()

            className = om.strutil.buildClassName(obj.SchemaName, obj.SchemaCategory, obj.MetadataModel);

            fprintf('Generated schema %s\n', className)
        end
    end
    
    methods (Access = private)

        function name = fixInvalidMatlabNames(obj, name, schemaName)
            
            name = replace(name, '-', '_');

            if obj.IsControlledTerm
                fcnName = strjoin({'om', 'generator', 'translations', schemaName}, '.');
                filepath = which( fcnName );
                if ~isempty(filepath)

                    C = feval(fcnName);
                    for i = 1:size(C, 1)
                        name = strrep(name, C{i,1}, C{i,2});
                    end
                end
            end
        end

        function parseSchema(obj)
        %parseSchema Get some overview information from the schema

            schemaStr = fileread(obj.SchemaClassFilePath);

            obj.Schema = jsondecode(schemaStr);

            schemaTypeSplit = strsplit(obj.Schema.x_type, '/');
            
            obj.SchemaName = schemaTypeSplit{end};
            
            % Get submodule from filepath.
            splitFilePath = strsplit(obj.SchemaClassFilePath, filesep);
            if isempty( regexp(splitFilePath{end-1}, 'v\d{1}', 'match') )
                obj.SchemaCategory = matlab.lang.makeValidName(splitFilePath{end-1});
            end

            obj.MetadataModel = schemaTypeSplit{end-1};
            obj.ClassName = obj.SchemaName;
            
            if strcmp(obj.MetadataModel, 'controlledTerms')
                obj.IsControlledTerm = true;
            end

            % Add superclasses
            obj.resolveSuperclasses();
        end
        
        function linkedPropertyInfo = detectLinkedPropertyInformation(obj, linkType)
        %detectLinkedPropertyInformation Detect information about linked properties    
            % INPUTS:
            %   obj
            %   linkType : 'x_linkedTypes' | 'x_embeddedTypes'

            if nargin < 2
                linkType = 'x_linkedTypes'; 
            end

            propertyNames = fieldnames(obj.Schema.properties);
            
            linkedPropertyInfo = {};

            for i = 1:numel(propertyNames)
                
                thisPropertyName = propertyNames{i};
                thisPropertySpecification = obj.Schema.properties.(thisPropertyName);

                if isfield(thisPropertySpecification, linkType)
                    linkedPropertyInfo{end+1} = struct(thisPropertyName, {thisPropertySpecification.(linkType)});
                end
            end
        end

        function assignOutputFile(obj)

            openMindsFolderPath = om.Constants.getRootPath();
            schemaFolderPath = fullfile( openMindsFolderPath, 'schemas', ...
                                 'matlab');
            
            if isempty(obj.SchemaCategory)
                schemaPackage = {'openminds', obj.MetadataModel};
            else
                schemaPackage = {'openminds', obj.MetadataModel, obj.SchemaCategory};
            end

            schemaPackage = lower( strcat('+', schemaPackage) );

            filename = [obj.SchemaName, '.m'];
            obj.Filepath = fullfile(schemaFolderPath, schemaPackage{:}, filename );
        end
        
    end

    methods (Access = protected) % Implement methods from superclass

        function writePropertyBlocks(obj)

            % Write constant and hidden class properties
            if isfield(obj.Schema, 'x_type')
                obj.writeXTypePropertyBlock()
            else
                % This is only the case for "abstract" schemas, and is not
                % relevant after starting to use the schemas from the
                % openMINDS documentation branch.
            end

            % Todo: remove?
            obj.writeSchemaCategoryPropertyBlock()

            obj.writeRequiredPropertyBlock()
            
            if obj.IsControlledTerm
                % pass
            else
                obj.writeSchemaProperties()
                obj.writeLinkedPropertyBlock()
            end
        end
    
        function writeEnumerationBlock(obj)
        %writeEnumerationBlock Enumeration block is only written for
        %controlled term schemas
            
            if obj.IsControlledTerm
                %instanceList = om.dir.instance('controlledTerms', obj.SchemaName);

                instanceTable = obj.getInstancesForSchema(obj.SchemaName, 'controlledTerms');
                numInstances = size(instanceTable, 1);
                
                % Write enumeration block
                obj.startEnumerationBlock()
                for i = 1:numInstances
                    name = instanceTable.SchemaName(i);
                    name = obj.fixInvalidMatlabNames(name, obj.SchemaName);

                    obj.addEnumValue(name)
                end
                obj.endEnumerationBlock()
            end
        end
    
        function writeEventBlocks(obj)
        end
            
        function writeMethodBlocks(obj)
            obj.startMethodsBlock()
            obj.startConstructor()

            % Todo:
            % Assign input variables to properties.
            
            obj.endFunctionBlock()
            obj.endMethodsBlock()
        end

    end

    methods (Access = private) % Specific methods for writing class member blocks
        
        function writeXTypePropertyBlock(obj)
            obj.startPropertyBlock('Constant', 'Hidden')
            obj.addProperty('X_TYPE', 'DefaultValue', ['"',obj.Schema.x_type,'"'])
            obj.endPropertyBlock()
        end

        function writeSchemaCategoryPropertyBlock(obj)

            if isfield(obj.Schema, 'x_categories')
                schemaCategories = obj.cellArrayToTextString(obj.Schema.x_categories);
            else
                schemaCategories = '{}';
            end

            if ~obj.IsAbstract
                % Write constant and hidden class properties
                obj.startPropertyBlock('SetAccess = immutable', 'Hidden')
                obj.addProperty('X_CATEGORIES', 'DefaultValue', schemaCategories)
                obj.endPropertyBlock()
            end
        end

        function writeRequiredPropertyBlock(obj)

            % Write required and constant properties
            if isfield(obj.Schema, 'required')
                required = obj.cellArrayToTextString(obj.Schema.required);
            else
                required = '{}';
            end
            
            obj.startPropertyBlock('Access = protected')
            obj.addProperty('Required_', 'DefaultValue', required)
            obj.endPropertyBlock()
        end

        function writeLinkedPropertyBlock(obj)

            obj.startPropertyBlock('Constant', 'Hidden')
            
            schemaClassPropertyNames = {'LINKED_PROPERTIES', 'EMBEDDED_PROPERTIES'};
            schemaPropertyAttributeNames = {'x_linkedTypes', 'x_embeddedTypes'};
            
            for iPropName = 1:2
                
                thisPropName = schemaClassPropertyNames{iPropName};
                thisAttrName = schemaPropertyAttributeNames{iPropName};

                linkedPropertyInfo = obj.detectLinkedPropertyInformation(thisAttrName);
                
                obj.appendLine(2, sprintf("%s = struct(...", thisPropName))
                for i = 1:numel(linkedPropertyInfo)
                    keyName = fieldnames(linkedPropertyInfo{i});
                    keyName = keyName{1};
                    linkedTypes = linkedPropertyInfo{i}.(keyName);
                    linkedTypesStr = obj.cellArrayToTextString(linkedTypes);
                
                    if i==numel(linkedPropertyInfo)
                        lineBreak = ' ...';
                    else
                        lineBreak = ', ...';
                    end
                    obj.appendLine(3, sprintf("'%s', {%s}%s", keyName, linkedTypesStr, lineBreak))
                end
                obj.appendLine(2, ')')

            end

            obj.endPropertyBlock()
            %obj.writeLinkedPropertyBlo
        end

        function writeSchemaProperties(obj)

            if isfield(obj.Schema, 'properties')
                obj.startPropertyBlock()
                propertyNames = fieldnames(obj.Schema.properties);
                for i = 1:numel(propertyNames)
                    if i~=1
                        obj.appendLine(2, "")
                    end
                    propertyAttr = obj.Schema.properties.(propertyNames{i});
                    obj.addSchemaProperty(propertyNames{i}, propertyAttr);
                end
                obj.endPropertyBlock()
            else
                
            end
        end

        function addSchemaProperty(obj, propertyName, propertyAttributes)
            
            % Store fieldnames of property attributes and use this to check
            % that all attributes have been handled.
            attributeNames = fieldnames(propertyAttributes);
            
            % Initialize poperty attribute variables.
            validationFcnStr = '';
            validationFcnStr = string.empty;

            if isfield(propertyAttributes, 'x_instruction')
                description = propertyAttributes.x_instruction;
                attributeNames = setdiff(attributeNames, 'x_instruction');
            else
                description = 'N/A';
            end

            newStr = sprintf('%% %s', description);
            obj.appendLine(2, newStr)
            
            % Get data size
            if isfield(propertyAttributes, 'type')
                if strcmp(propertyAttributes.type, 'array')
                    sizeAttribute = '(1,:)';
                elseif strcmp(propertyAttributes.type, 'integer')
                    sizeAttribute = '(1,:)';
                    validationFcnStr(end+1) = sprintf('mustBeSpecifiedLength(%s, 0, 1)', propertyName);
                else
                    sizeAttribute = '(1,1)';
                end
                attributeNames = setdiff(attributeNames, 'type');
            else
                sizeAttribute = '(1,1)';
            end


            % Get data type
            if isfield(propertyAttributes, 'x_linkedTypes') || isfield(propertyAttributes, 'x_embeddedTypes')
                if isfield(propertyAttributes, 'x_linkedTypes')
                    schemaNames = propertyAttributes.x_linkedTypes;
                    attributeNames = setdiff(attributeNames, 'x_linkedTypes');
                elseif isfield(propertyAttributes, 'x_embeddedTypes')
                    schemaNames = propertyAttributes.x_embeddedTypes;
                    attributeNames = setdiff(attributeNames, 'x_embeddedTypes');
                end
                
                if strcmp(sizeAttribute, '(1,1)')
                    sizeAttribute = '(1,:)';
                    validationFcnStr(end+1) = sprintf('mustBeSpecifiedLength(%s, 0, 1)', propertyName);
                end

                if ~isempty(schemaNames)
                    S = warning(char(obj.DEBUG), 'OPENMINDS:SchemaNotFound');
                    clsNames = cellfun(@(uri) om.strutil.classNameFromUri(uri), schemaNames, 'UniformOutput', false);
                    warning(S.state, 'OPENMINDS:SchemaNotFound')

                    isEmptyNames = cellfun(@isempty, clsNames);
                    clsNames(isEmptyNames) = [];
                else
                    clsNames = {};
                end
                
                % Big todo: Figure out what to do here!
%                 if numel(clsNames) > 1
%                     dataType = sprintf('{%s}', strjoin(clsNames, ', '));
%                 else
%                     dataType = clsNames{1};
%                 end

                if isempty(clsNames)
                    dataType = '';
                elseif numel(clsNames) == 1
                    dataType = clsNames{1};
                else
                    %dataType = 'cell';
                    %validationFcnStr(end+1) = obj.getMultiTypeValidationFunctionString(propertyName, clsNames);

                    dataType = clsNames{1};
                    %warning('Multiple schemas allowed for property %s of schema %s', propertyName, obj.SchemaName)
                end

            
            elseif isfield(propertyAttributes, 'x_linkedCategories')
                clsNames = cellfun(@(str) om.strutil.buildClassName(str, '', 'category'), propertyAttributes.x_linkedCategories, 'UniformOutput', false);
                %dataType = sprintf('{%s}', strjoin(clsNames, ', '));
                attributeNames = setdiff(attributeNames, 'x_linkedCategories');
                dataType = clsNames{1};
                if numel(clsNames) > 1
                    warning('Multiple linked categories for property %s of schema %s', propertyName, obj.SchemaName)
                end

            elseif isfield(propertyAttributes, 'type')
                if strcmp(propertyAttributes.type, 'array')
                    if isfield(propertyAttributes, 'items')
                        itemDef = propertyAttributes.items;
                        itemFields = fieldnames(itemDef);
                        if isfield(itemDef, 'type')
                            dataType = itemDef.type;
                            itemFields = setdiff(itemFields, 'type');
                        else
                            
                        end
                        % Todo: note: item is a nested attribute field....
                        if ~isempty(itemFields)
                            if ~strcmp(itemFields{1}, 'x_formats')
                                disp(['array item attributes: ', strjoin(itemFields, ', ')])
                            end

                            if strcmp(dataType, 'string')
                                % todo create validator
                            else
                                disp(['array item type: ', dataType])
                            end
                        end

                        attributeNames = setdiff(attributeNames, 'items');
                    end
                else
                    dataType = propertyAttributes.type;
                end

                % Convert some datatypes to matlab types.
                switch dataType

                    case {'number'}
                        dataType = 'double';

                    case {'integer'}
                        dataType = 'uint64';

                    case 'float'
                        dataType = 'double';

                    case 'string'
                        % pass

                    otherwise
                        disp(['datatype: ', propertyAttributes.type])
                end
            else
                disp('a')
            end

            % Todo: get validation function.
            if any(isfield(propertyAttributes, {'minItems', 'maxItems', 'uniqueItems', 'maxLength', 'minLength', 'pattern', 'minimum', 'maximum'}))

                validationFcnStr = horzcat(validationFcnStr, obj.getValidationFunction(propertyName, propertyAttributes));
                attributeNames = setdiff(attributeNames, {'minItems', 'maxItems', 'uniqueItems', 'maxLength', 'minLength', 'pattern', 'minimum', 'maximum'});
            end

            if isfield(propertyAttributes, 'x_formats')
                assert( strcmp( dataType, 'string'), 'Format for non-string' )
                if any( contains( propertyAttributes.x_formats, {'date', 'time', 'date-time'} ))
                    dataType = 'datetime';
                elseif any( contains( propertyAttributes.x_formats, 'email' ) )
                    % Todo: mustBeValidEmail legges til validationFcnStr
                elseif any( contains( propertyAttributes.x_formats, 'iri' ) )
                    % Todo: mustBeValidIri. What does this mean???
                elseif any( contains( propertyAttributes.x_formats, 'ECMA262' ) )
                    % Todo: mustBeValidECMA. What does this mean???
                else
                    disp( propertyAttributes.x_formats)
                end
                attributeNames = setdiff(attributeNames, {'x_formats'});
            end

            % Todo: Implement string length...
            if ~isempty(attributeNames)
                for k = 1:numel(attributeNames)
                    switch attributeNames{k}
                        case 'title'
                            str = propertyAttributes.title;
                            if strcmp(str, propertyName)
                                % pass
                            else
                                disp(['title: ', str])
                            end
                        case 'description'
                            str = propertyAttributes.description;
                            %disp(['description: ', str])
                        otherwise
                            disp(['additional attributenames: ', attributeNames])
                    end
                end
            end

            if isempty(validationFcnStr)
                obj.addProperty(propertyName, 'Size', sizeAttribute, ...
                    'Type', dataType)
                %newStr = sprintf('%s %s %s', propertyName, sizeAttribute, dataType);
            else

                validationFcnStr = sprintf("{%s}", strjoin(validationFcnStr, ", "));

                obj.addProperty(propertyName, 'Size', sizeAttribute, ...
                    'Type', dataType, 'Validator', validationFcnStr)
                %newStr = sprintf('%s %s %s %s', propertyName, sizeAttribute, dataType, validationFcnStr);
            end
            
            %newStr = obj.indentLine(newStr, 2);
            %obj.appendLine(newStr)
            %obj.appendLine('')
        end

    end

    methods
        function schemaClassName = get.SchemaClassName(obj)
            schemaClassName = obj.SchemaName; 
            schemaClassName(1) = upper(schemaClassName(1));
        end

%         function tf = get.HasSuperclass(obj)
%             tf = isfield(obj.Schema, 'x_extends');
%         end

        function tf = get.IsOfCategory(obj)
            tf = isfield(obj.Schema, 'x_categories');
        end

        function updateSchemaClassFilePath(obj)
            obj.SchemaClassFilePath = om.strutil.buildClassPath(...
                obj.SchemaName, obj.SchemaCategory, obj.MetadataModel);
        end
    end

    methods (Access = private)

        function startConstructor(obj)

            if obj.IsControlledTerm
                obj.appendLine(2, sprintf('function obj = %s(name)', obj.SchemaClassName))
            else
                obj.appendLine(2, sprintf('function obj = %s(varargin)', obj.SchemaClassName))
            end

            if obj.HasSuperclass
                 obj.appendLine(3, 'required = obj.getSuperClassRequiredProperties();')
                 obj.appendLine(3, 'obj.Required = [required, obj.Required_];')
                 obj.appendLine(3, "")
            end

            if obj.IsControlledTerm
                obj.writeEnumSwitchBlock()
            else
                obj.appendLine(3, sprintf('obj.assignPVPairs(varargin{:})'))
                obj.appendLine(3, "")
            end

        end

        function writeEnumSwitchBlock(obj)
        %writeEnumSwitchBlock Enumeration switcher for controlled instances
            
            %instanceList = om.dir.instance('controlledTerms', obj.SchemaName);
            
            instances = obj.getInstancesForSchema(obj.SchemaName, 'controlledTerms');
            numInstances = size(instances, 1);

            obj.appendLine(3, 'switch name')
            for i = 1:numInstances

                iName = instances.SchemaName(i);
                iName = fixInvalidMatlabNames(obj, iName, obj.SchemaName);

                obj.appendLine(4, sprintf('case ''%s''', iName))

                %jsonStr = om.fileio.readInstance(instanceList(i).Name, obj.SchemaName, 'controlledTerms');
                
                jsonStr = fileread(instances.Filepath(i));

                jsonStr = strrep(jsonStr, '''', ''''''); %If character array contains ', need to replace with ''
                data = om.json.decode(jsonStr);

                propNames = {'at_id', 'at_type', 'name', 'definition', 'description', 'interlexIdentifier', 'knowledgeSpaceLink', 'preferredOntologyIdentifier', 'synonym'};
                for j = 1:numel(propNames)
                    if isfield(data, propNames{j})
                        jName = propNames{j};
                        jValue = data.(propNames{j});
                        if isa(jValue, 'cell')
                            jValue = cellfun(@(str) sprintf('''%s''', str), jValue, 'UniformOutput', false);
                            jValue = strjoin(jValue, ', ');
                            jValue = sprintf( '{%s}', jValue );
                        elseif isa(jValue, 'char') || isa(jValue, 'string')
                            jValue = sprintf('''%s''', jValue);
                        elseif isempty(jValue)
                            jValue = '''''';
                        end

                        obj.appendLine(5, sprintf('obj.%s = %s;', jName, jValue))
                    end
                end
                
                obj.appendLine(4, "")
                %obj.writeEmptyLine()
            end
            obj.appendLine(3, 'end')
        end
    end
    
    methods (Access = private)
        
        function str = getValidationFunction(obj, name, attr)
            
            str = string.empty;

            if isfield(attr, 'maxItems')
                if isfield(attr, 'minItems')
                    minItems = attr.minItems;
% %                     if isfield(obj.Schema, 'required')
% %                         if ~any(strcmp(obj.Schema.required, name))
% %                             minItems = 0;
% %                         end
% %                     end
                else
                    minItems = 0;
                end

                maxItems = attr.maxItems;
                
                str(end+1) = sprintf("mustBeSpecifiedLength(%s, %d, %d)", name, minItems, maxItems);
            
            elseif isfield(attr, 'uniqueItems')
                str(end+1) = sprintf('mustBeListOfUniqueItems(%s)', name);

            elseif isfield(attr, 'minLength') || isfield(attr, 'maxLength')
                
                if isfield(attr, 'minLength')
                    minLength = attr.minLength;
                else
                    minLength = 0;
                end

                if isfield(attr, 'maxLength')
                    maxLength = attr.maxLength;
                else
                    maxLength = inf;
                end
                str(end+1) = sprintf('mustBeValidStringLength(%s, %d, %d)', name, minLength, maxLength);
            
            elseif isfield(attr, 'pattern')
                
                if contains(attr.pattern, 'archive.softwareheritage')
                    warning('SWHID str pattern validation is hard-coded')
                    escapedStrPattern = "^https://archive.softwareheritage.org/swh:1:(cnt|dir|rel|rev|snp):[0-9a-f]{40}(;(origin|visit|anchor|path|lines)=[^ \\t\\r\\n\\f]+)*$";
                
                else
                    escapedStrPattern = attr.pattern;
                end

                str(end+1) = sprintf('mustMatchPattern(%s, ''%s'')', name, escapedStrPattern);

            elseif isfield(attr, 'minimum') || isfield(attr, 'maximum')

                if isfield(attr, 'minimum')
                    minValue = attr.minimum;
                else
                    minValue = nan;
                end

                if isfield(attr, 'maximum')
                    maxValue = attr.maximum;
                else
                    maxValue = nan;
                end

                str(end+1) = sprintf('mustBeInteger(%s)', name);

                if ~isnan(minValue) && ~isnan(maxValue)
                    str(end+1) = sprintf( 'mustBeInRange(%s, %d, %d)}', name, minValue, maxValue );
                elseif isnan(minValue)
                    str(end+1) = sprintf( 'mustBeLessThanOrEqual(%s, %d)}', name, maxValue );
                elseif isnan(maxValue)
                    str(end+1) = sprintf( 'mustBeGreaterThanOrEqual(%s, %d)', name, minValue );
                end
            end
        end
    
        function str = getMultiTypeValidationFunctionString(obj, propertyName, clsNames)

            functionName = 'mustBeType';

            validTypes = obj.cellArrayToTextString(clsNames);

            str = sprintf("%s(%s, %s)", functionName, propertyName, validTypes);
        end
    end
    
    methods (Static)
        
        function instances = getInstancesForSchema(schemaName, modelName)
        
            % Make singleton class that can be reset...
            persistent allInstancesTable
            
            if isempty(allInstancesTable)
                allInstancesTable = om.internal.dir.listSourceSchemas(...
                    'SchemaType', 'instances', 'SchemaFileExtension', '.jsonld');
            end

            % Todo: match on camel case!!!

            isRequested = allInstancesTable.ModuleName == modelName & strcmpi(allInstancesTable.SubModuleName, schemaName);
            
            instances = allInstancesTable(isRequested, :);
        end

    end

end
