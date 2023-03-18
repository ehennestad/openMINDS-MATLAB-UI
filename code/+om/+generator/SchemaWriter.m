classdef SchemaWriter < ClassWriter
%SchemaWriter Translate openMINDS schemas to matlab classes    


    
%     TODO:
%     - [ ] Collect names of linked and embedded properties when parsing 
%     - [ ] Add LinkedProperties and EmbeddedProperties as Constant
%           property block
%     - [ ] Assign name property for controlled terms

    properties (Constant)
        DEBUG (1,1) matlab.lang.OnOffSwitchState = 'off'
    end
    
    properties (SetAccess = private)
        Schema
    end

    properties (Access = private)
        SchemaName = ''
        SchemaCategory = ''
        SchemaModule = ''
    end

    properties (Dependent)
        IsOfCategory
        SchemaClassName
    end

    properties (Access = private)
        SchemaClassFilePath
        SchemaClassFileID % ??
        SchemaCodeStr = "";
        IsControlledTerm = false
    end


    methods
        function obj = SchemaWriter(schemaFilepath, action)

            arguments
                schemaFilepath
                action
            end

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
            obj.addSuperclass('openminds.abstract.Schema')

            % Todo: Determine if it extends controlled term
            hasMoreSuperclasses = isfield(obj.Schema, 'x_extends');

            if hasMoreSuperclasses
                disp('has more superclasses, %s', obj.SchemaName)
            end
        end

        function writeSchemaClassdef(obj)
            
            obj.SchemaCodeStr = ''; % Reset

            if obj.HasSuperclass  % Create superclass
                [schemaCategory, schemaName] = om.strutil.splitSchemaPath(obj.Schema.x_extends);
                if ~om.existSchema(schemaName, schemaCategory, obj.SchemaModule) 
                    om.createMatlabSchemaClass(schemaName, schemaCategory, obj.SchemaModule)
                end
                superclassName = om.strutil.buildClassName(schemaName, schemaCategory, obj.SchemaModule);
            else
                superclassName = 'openminds.abstract.Schema';
            end

            % Make cell array, because we might add more superclasses below.
            superclassName = {superclassName};


            if contains('openminds.controlledterms.ControlledTerm', superclassName)
                obj.IsControlledTerm = true;
                superclassName = [superclassName, 'openminds.abstract.Instance'];
            end

            if obj.IsOfCategory
                categories = obj.Schema.x_categories;
                for i = 1:numel(categories)
                    om.createMatlabCategoryClass(categories{i}, obj.SchemaModule)                   
                end
                superclassName = [superclassName, cellfun(@(str) om.strutil.buildClassName(str, '', 'category'), categories, 'UniformOutput', false)];
            end

            % Write class definition
            obj.startClassDef(superclassName)
            
            if isfield(obj.Schema, 'x_type')
                % Write constant and hidden class properties
                obj.startPropertyBlock('Constant', 'Hidden')
                obj.addProperty('X_TYPE', ['"',obj.Schema.x_type,'"'])
                obj.endPropertyBlock()
            end

            if isfield(obj.Schema, 'x_categories')
                schemaCategories = cellfun(@(c) sprintf('''%s''', c), obj.Schema.x_categories, 'UniformOutput', false);
                schemaCategories = sprintf('{%s}', strjoin(schemaCategories, ', '));
            else
                schemaCategories = '{}';
            end

            if ~obj.IsAbstract
                % Write constant and hidden class properties
                obj.startPropertyBlock('SetAccess = immutable', 'Hidden')
                obj.addProperty('X_CATEGORIES', schemaCategories)
                obj.endPropertyBlock()
            end

            % Write required and constant properties
            if isfield(obj.Schema, 'required')
                required = cellfun(@(c) sprintf('''%s''', c), obj.Schema.required, 'UniformOutput', false);
                required = sprintf('{%s}', strjoin(required, ', '));
            else
                required = '{}';
            end
            
            
            obj.startPropertyBlock('Access = private')
            obj.addProperty('Required_', required)
            obj.endPropertyBlock()

           
            if isfield(obj.Schema, 'properties')
                obj.startPropertyBlock()
                propertyNames = fieldnames(obj.Schema.properties);
                for i = 1:numel(propertyNames)
                    if i~=1
                        obj.writeEmptyLine()
                    end
                    propertyAttr = obj.Schema.properties.(propertyNames{i});
                    obj.addSchemaProperty(propertyNames{i}, propertyAttr);
                end
                obj.endPropertyBlock()
            else
                
            end

            if contains('openminds.controlledterms.ControlledTerm', superclassName)
                instanceList = om.dir.instance('controlledTerms', obj.SchemaName);
                % Write enumeration block
                obj.startEnumBlock()
                for i = 1:numel(instanceList)
                    obj.addEnumValue(instanceList(i).Name)
                end
                obj.endPropertyBlock()
            end
            
            obj.startMethodsBlock()
            obj.startConstructor()

            % Todo:
            % Assign input variables to properties.
            
            obj.endFunctionBlock()

            obj.endMethodsBlock()

            obj.endClassDef()
        end

        function show(obj)
            fprintf(obj.SchemaCodeStr)
        end

        function update(obj)
            obj.writeSchemaClassdef()
            obj.updateSchemaClassFilePath()
            om.fileio.writeSchemaClass(obj.SchemaClassFilePath, obj.SchemaCodeStr)

            className = om.strutil.buildClassName(obj.SchemaName, obj.SchemaCategory, obj.SchemaModule);

            fprintf('Generated schema %s\n', className)
        end
    end
    
    methods (Access = private)
        
        function parseSchema(obj)
            
            schemaStr = fileread(obj.SchemaClassFilePath);
            obj.Schema = jsondecode(schemaStr);

            schemaTypeSplit = strsplit(obj.Schema.x_type, '/');
            
            obj.SchemaName = schemaTypeSplit{end};
            
            % Get submodule from filepath.
            splitFilePath = strsplit(obj.SchemaClassFilePath, filesep);
            if isempty( regexp(splitFilePath{end-1}, 'v\d{1}', 'match') )
                obj.SchemaCategory = matlab.lang.makeValidName(splitFilePath{end-1});
            end

            obj.SchemaModule = schemaTypeSplit{end-1};
            obj.ClassName = obj.SchemaName;

            % Add superclasses
            obj.resolveSuperclasses();
            
        end
        
        function assignOutputFile(obj)

            openMindsFolderPath = om.Constants.getRootPath();
            schemaFolderPath = fullfile( openMindsFolderPath, 'schemas', ...
                                 'matlab');
            
            if isempty(obj.SchemaCategory)
                schemaPackage = {'openminds', obj.SchemaModule};
            else
                schemaPackage = {'openminds', obj.SchemaModule, obj.SchemaCategory};
            end

            schemaPackage = strcat('+', schemaPackage);

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

            obj.writeSchemaProperties()
        end
    
        function writeEnumerationBlock(obj)
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
                    validationFcnStr = sprintf('{mustBeSpecifiedLength(%s, 0, 1)}', propertyName);
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
                    dataType = clsNames{1};
                    warning('Multiple schemas allowed for property %s of schema %s', propertyName, obj.SchemaName)
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
                if ~isempty(validationFcnStr)
                    warning('Property %s has multiple validation functions', propertyName)
                end
                validationFcnStr = obj.getValidationFunction(propertyName, propertyAttributes);
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
                obj.SchemaName, obj.SchemaCategory, obj.SchemaModule);
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

            obj.appendLine(3, sprintf('obj.assignPVPairs(varargin{:})'))


            if obj.IsControlledTerm
                obj.writeEnumSwitchBlock()
            end

        end

        function writeEnumSwitchBlock(obj)
            instanceList = om.dir.instance('controlledTerms', obj.SchemaName);

            obj.writeLine(3, 'switch name')
            for i = 1:numel(instanceList)

                iName = replace(instanceList(i).Name, '-', '_');

                obj.writeLine(4, sprintf('case ''%s''', iName))

                jsonStr = om.fileio.readInstance(instanceList(i).Name, obj.SchemaName, 'controlledTerms');
                jsonStr = strrep(jsonStr, '''', ''''''); %If character array contains ', need to replace with ''
                data = om.json.decode(jsonStr);

                propNames = {'at_id', 'at_type', 'definition', 'description', 'interlexIdentifier', 'knowledgeSpaceLink', 'preferredOntologyIdentifier', 'synonym'};
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

                        obj.writeLine(5, sprintf('obj.%s = %s;', jName, jValue))
                    end
                end

                obj.writeEmptyLine()
            end
            obj.writeLine(3, 'end')
        end
    end
    
    methods (Access = private)
        
        function str = getValidationFunction(obj, name, attr)
            
            str = '';


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
                
                str = sprintf('{mustBeSpecifiedLength(%s, %d, %d)}', name, minItems, maxItems);
            
            elseif isfield(attr, 'uniqueItems')
                str = sprintf('{mustBeListOfUniqueItems(%s)}', name);

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
                str = sprintf('{mustBeValidStringLength(%s, %d, %d)}', name, minLength, maxLength);
            
            elseif isfield(attr, 'pattern')
                
                if contains(attr.pattern, 'archive.softwareheritage')
                    warning('SWHID str pattern validation is hard-coded')
                    escapedStrPattern = "^https://archive.softwareheritage.org/swh:1:(cnt|dir|rel|rev|snp):[0-9a-f]{40}(;(origin|visit|anchor|path|lines)=[^ \\t\\r\\n\\f]+)*$";
                
                else
                    escapedStrPattern = attr.pattern;
                end

                str = sprintf('{mustMatchPattern(%s, ''%s'')}', name, escapedStrPattern);

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

                if ~isnan(minValue) && ~isnan(maxValue)
                    valueCheckFcn = sprintf( 'mustBeInRange(%s, %d, %d)}', name, minValue, maxValue );
                elseif isnan(minValue)
                    valueCheckFcn = sprintf( 'mustBeLessThanOrEqual(%s, %d)}', name, maxValue );
                elseif isnan(maxValue)
                    valueCheckFcn = sprintf( 'mustBeGreaterThanOrEqual(%s, %d)', name, minValue );
                end

                str = sprintf('{mustBeInteger(%s), %s}', name, valueCheckFcn);

            end
        end
    
    end

end
