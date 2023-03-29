classdef ClassWriter < handle % ClassWriter

    
%     TODO:
%     - [ ] Collect names of linked and embedded properties when parsing 
%     - [ ] Add LinkedProperties and EmbeddedProperties as Constant
%           property block


    properties (SetAccess = private)
        Schema
    end

    properties (Access = private)
        SchemaName = ''
        SchemaCategory = ''
        SchemaModule = ''
        SchemaList
    end

    properties (Dependent)
        IsAbstract
        HasSuperclass
        IsOfCategory
        SchemaClassName
    end

    properties (Access = private)
        SchemaClassFilePath
        SchemaClassFileID
        SchemaCodeStr = "";
        IsControlledTerm = false
    end

    properties (Constant, Hidden)
        INDENTATION_WIDTH = 4;
    end


    methods 
        function obj = ClassWriter(schemaName, schemaCategory, schemaModule)

            arguments
                schemaName
                schemaCategory
                schemaModule char = 'core'
            end

            obj.SchemaName = schemaName;
            obj.SchemaCategory = schemaCategory;
            obj.SchemaModule = schemaModule;

            schemaStr = om.fileio.readSchema(schemaName, schemaCategory, schemaModule);
            obj.Schema = jsondecode(schemaStr);
            
            %obj.writeSchemaString()
            obj.update()
        end

    end

    methods
        function writeSchemaString(obj)
            
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
            obj.writeSchemaString()
            obj.updateSchemaClassFilePath()
            om.fileio.writeSchemaClass(obj.SchemaClassFilePath, obj.SchemaCodeStr)

            className = om.strutil.buildClassName(obj.SchemaName, obj.SchemaCategory, obj.SchemaModule);

            fprintf('Generated schema %s\n', className)
        end
    end

    methods
        function schemaClassName = get.SchemaClassName(obj)
            schemaClassName = obj.SchemaName; 
            schemaClassName(1) = upper(schemaClassName(1));
        end

        function tf = get.IsAbstract(obj)
            tf = ~isfield(obj.Schema, 'x_type');
        end

        function tf = get.HasSuperclass(obj)
            tf = isfield(obj.Schema, 'x_extends');
        end
        function tf = get.IsOfCategory(obj)
            tf = isfield(obj.Schema, 'x_categories');
        end


        function updateSchemaClassFilePath(obj)
            obj.SchemaClassFilePath = om.strutil.buildClassPath(...
                obj.SchemaName, obj.SchemaCategory, obj.SchemaModule);
        end
    end

    methods (Access = private)

        function startClassDef(obj, superclassName)
            
            className = obj.SchemaName; className(1) = upper(className(1));
            
            if ~exist("superclassName", "var") || isempty(superclassName)
                superclassName = "handle";
            end

            newStr = "classdef " + className + " < " + strjoin( superclassName, ' & ' );

            if obj.IsAbstract
                newStr = replace(newStr, "classdef ", "classdef (Abstract) ");
            end

            obj.SchemaCodeStr = obj.SchemaCodeStr + newStr + newline + newline;
        end

        function endClassDef(obj)
            obj.SchemaCodeStr = obj.SchemaCodeStr + 'end';
        end
        
        function startPropertyBlock(obj, varargin)
            if isempty(varargin)
                newStr = sprintf("properties");
            else
                newStr = sprintf("properties (%s)", strjoin(varargin, ', '));
            end
            newStr = obj.indentLine(newStr, 1);
            obj.SchemaCodeStr = obj.SchemaCodeStr + newStr + newline;
        end

        function addProperty(obj, propertyName, propertyDefaultValue, sizeAttr, typeAttr, validationAttr)
            newStr = propertyName + " = " + propertyDefaultValue; %(s)", strjoin(varargin, ', '));
            newStr = obj.indentLine(newStr, 2);
            obj.SchemaCodeStr = obj.SchemaCodeStr + newStr + newline;
        end

        function addSchemaProperty(obj, propertyName, propertyAttributes)
            
            % Store fieldnames of property attributes and use this to check
            % that all attributes have been handled.
            attributeNames = fieldnames(propertyAttributes);
            
            if isfield(propertyAttributes, 'x_instruction')
                description = propertyAttributes.x_instruction;
                attributeNames = setdiff(attributeNames, 'x_instruction');
            else
                description = 'N/A';
            end

            newStr = sprintf('%% %s', description);
            newStr = obj.indentLine(newStr, 2);
            obj.SchemaCodeStr = obj.SchemaCodeStr + newStr + newline;
            
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

                clsNames = cellfun(@(uri) om.strutil.classNameFromUri(uri), schemaNames, 'UniformOutput', false);
                isEmptyNames = cellfun(@isempty, clsNames);
                clsNames(isEmptyNames) = [];
                
                % Big todo: Figure out what to do here!
%                 if numel(clsNames) > 1
%                     dataType = sprintf('{%s}', strjoin(clsNames, ', '));
%                 else
%                     dataType = clsNames{1};
%                 end

                dataType = clsNames{1};

            
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
                            disp(itemFields)
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

                    otherwise
                        disp(['datatype', propertyAttributes.type])
                end
            else
                disp('a')
            end

            % Todo: get validation function.
            if any(isfield(propertyAttributes, {'minItems', 'maxItems', 'uniqueItems', 'maxLength', 'minLength'}))
                if exist('validationFcnStr', 'var') && ~isempty(validationFcnStr)
                    disp('a')
                end
                validationFcnStr = obj.getValidationFunction(propertyName, propertyAttributes);
                attributeNames = setdiff(attributeNames, {'minItems', 'maxItems', 'uniqueItems', 'maxLength', 'minLength'});
            else
                validationFcnStr = '';
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

            if isfield(propertyAttributes, 'pattern')
                fprintf('%s: %s: pattern: %s\n', obj.SchemaName, propertyName, propertyAttributes.pattern)
                attributeNames = setdiff(attributeNames, 'pattern');
            end

            % Todo: Implement string length...


            if ~isempty(attributeNames)
                disp(attributeNames)
            end
            
            if isempty(validationFcnStr)
                newStr = sprintf('%s %s %s', propertyName, sizeAttribute, dataType);
            else
                newStr = sprintf('%s %s %s %s', propertyName, sizeAttribute, dataType, validationFcnStr);
            end
            
            newStr = obj.indentLine(newStr, 2);
            obj.appendLine(newStr)
            %obj.appendLine('')
        end

        function endPropertyBlock(obj)
            newStr = obj.indentLine('end', 1);
            obj.SchemaCodeStr = obj.SchemaCodeStr + newStr + newline + newline;
        end


        % function that starts writing an enumeration block
        function startEnumBlock(obj)
            newStr = sprintf("enumeration");
            newStr = obj.indentLine(newStr, 1);
            obj.SchemaCodeStr = obj.SchemaCodeStr + newStr + newline;
        end

        % function that adds an enumeration value
        function addEnumValue(obj, enumValue)
            enumValue = replace(enumValue, '-', '_');
            newStr = sprintf("%s('%s')", enumValue, enumValue);
            newStr = obj.indentLine(newStr, 2);
            obj.SchemaCodeStr = obj.SchemaCodeStr + newStr + newline;
        end

        function startMethodsBlock(obj, varargin)
            if isempty(varargin)
                newStr = sprintf("methods");
            else
                newStr = sprintf("methods (%s)", strjoin(varargin, ', '));
            end
            newStr = obj.indentLine(newStr, 1);
            obj.SchemaCodeStr = obj.SchemaCodeStr + newStr + newline;
        end
        
        function endMethodsBlock(obj)
            obj.endPropertyBlock()
        end

        function startConstructor(obj)

            if obj.IsControlledTerm
                obj.writeLine(2, sprintf('function obj = %s(name)', obj.SchemaClassName))
            else
                obj.writeLine(2, sprintf('function obj = %s()', obj.SchemaClassName))
            end

            if obj.HasSuperclass
                 obj.writeLine(3, 'required = obj.getSuperClassRequiredProperties();')
                 obj.writeLine(3, 'obj.Required = [required, obj.Required_];')
                 obj.writeEmptyLine()
            end

            if obj.IsControlledTerm
                obj.writeEnumSwitchBlock()
            end

        end

        function startFunctionBlock(obj)

        end

        function endFunctionBlock(obj)
            newStr = obj.indentLine('end', 2);
            obj.SchemaCodeStr = obj.SchemaCodeStr + newStr + newline;
        end

        function writeLine(obj, numIndent, str)
            newStr = obj.indentLine(str, numIndent);
            obj.SchemaCodeStr = obj.SchemaCodeStr + newStr + newline;
        end

        function appendLine(obj, newStr)
            obj.SchemaCodeStr = obj.SchemaCodeStr + newStr + newline;
        end

        function writeEmptyLine(obj)
            obj.SchemaCodeStr = obj.SchemaCodeStr + newline;
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
            end
        end
    end

    methods (Static)

        function str = indentLine(str, numIndents)
            indentationWidth = numIndents * om.ClassWriter.INDENTATION_WIDTH;
            indentationStr = repmat(' ', 1, indentationWidth);
            str = sprintf('%s%s', indentationStr, str);
        end

    end
    
end
