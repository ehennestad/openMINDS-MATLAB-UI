classdef ClassWriter < handle
    


    properties (SetAccess = private)
        Schema
    end

    properties (Access = private)
        SchemaName = ''
        SchemaCategory = ''
        SchemaModule = ''
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
                om.createMatlabSchemaClass(schemaName, schemaCategory, obj.SchemaModule)
                superclassName = om.strutil.buildClassName(schemaName, schemaCategory, obj.SchemaModule);
            else
                superclassName = 'openminds.abstract.OpenMINDSSchema';
            end

            % Make cell array, because we might add more superclasses below.
            superclassName = {superclassName};

            if obj.IsOfCategory
                categories = obj.Schema.x_categories;
                for i = 1:numel(categories)
                    om.createMatlabCategoryClass(categories{i}, obj.SchemaModule)                   
                end
                superclassName = [superclassName, cellfun(@(str) sprintf('%s.category.%s', obj.SchemaModule, PascalCase(str)), categories, 'UniformOutput', false)];
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
                obj.startPropertyBlock('SetAccess = immutable')
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
            
            if obj.IsAbstract
                obj.startPropertyBlock('Access = private')
            else
                obj.startPropertyBlock('SetAccess = immutable')
            end
            obj.addProperty('Required', required)
            obj.endPropertyBlock()

            obj.startPropertyBlock()
            if isfield(obj.Schema, 'properties')
                propertyNames = fieldnames(obj.Schema.properties);
                for i = 1:numel(propertyNames)
                    if i~=1
                        obj.writeEmptyLine()
                    end
                    propertyAttr = obj.Schema.properties.(propertyNames{i});
                    obj.addSchemaProperty(propertyNames{i}, propertyAttr);
                end
            else
                disp('a')
            end
            obj.endPropertyBlock()

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
            rootPath = om.Preferences.get('MSchemaDirectory');
            folderPath = fullfile(rootPath, ['+', lower(obj.SchemaModule)],...
                ['+', lower(obj.SchemaCategory)]);
            obj.SchemaClassFilePath = fullfile(folderPath, [obj.SchemaClassName, '.m']);

            if ~exist(folderPath, 'dir')
                mkdir(folderPath)
            end
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

            if isfield(propertyAttributes, 'x_instruction')
                description = propertyAttributes.x_instruction;
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
                    disp(['type', '-size set to 1,1-',propertyAttributes.type])
                    sizeAttribute = '(1,1)';
                end
            else
                sizeAttribute = '(1,1)';
            end


            % Get data type
            if isfield(propertyAttributes, 'x_linkedTypes') || isfield(propertyAttributes, 'x_embeddedTypes')
                if isfield(propertyAttributes, 'x_linkedTypes')
                    schemaNames = propertyAttributes.x_linkedTypes;
                elseif isfield(propertyAttributes, 'x_embeddedTypes')
                    schemaNames = propertyAttributes.x_embeddedTypes;
                end
                clsNames = cellfun(@(uri) om.strutil.classNameFromUri(uri), schemaNames, 'UniformOutput', false);
                
                if numel(clsNames) > 1
                    dataType = sprintf('{%s}', strjoin(clsNames, ', '));
                else
                    dataType = clsNames{1};
                end
            
            elseif isfield(propertyAttributes, 'x_linkedCategories')
                clsNames = cellfun(@(str) sprintf('%s.category.%s', obj.SchemaModule, PascalCase(str)), propertyAttributes.x_linkedCategories, 'UniformOutput', false);
                dataType = sprintf('{%s}', strjoin(clsNames, ', '));

            elseif isfield(propertyAttributes, 'type')
                if strcmp(propertyAttributes.type, 'array')
                    if isfield(propertyAttributes, 'items')
                        itemDef = propertyAttributes.items;
                        if isfield(itemDef, 'type')
                            dataType = itemDef.type;
                        else
                            disp('a')
                        end
                    end
                else
                    switch propertyAttributes.type
                        case {'string'}
                            dataType = propertyAttributes.type;

                        case {'number'}
                            dataType = 'double';
                            disp('b')

                        case {'integer'}
                            dataType = 'unit64';

                        case 'float'
                            dataType = 'double';

                        otherwise
                            disp(['datatype', propertyAttributes.type])
                    end
                end
            else
                disp('a')
            end

            % Todo: get validation function.
            if any(isfield(propertyAttributes, {'minItems', 'maxItems', 'uniqueItems'}))
                validationFcnStr = obj.getValidationFunction(propertyName, propertyAttributes);
            else
                validationFcnStr = '';
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

            obj.writeLine(2, sprintf('function obj = %s()', obj.SchemaClassName))

            if obj.HasSuperclass
                 obj.writeLine(3, 'required = obj.getSuperClassRequiredProperties();')
                 obj.writeLine(3, 'obj.Required = [required, obj.Required];')
                 obj.writeEmptyLine()
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

    end
    
    methods (Access = private)
        function str = getValidationFunction(obj, name, attr)
            
            str = '';


            if isfield(attr, 'maxItems')
                if isfield(attr, 'minItems')
                    minItems = attr.minItems;
                else
                    minItems = 0;
                end

                maxItems = attr.maxItems;
                
                str = sprintf('{mustBeSpecifiedLength(%s, %d, %d)}', name, minItems, maxItems);

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


function mustBeSpecifiedLength(value, minLength, maxLength)
    
    if length(value) < minLength
        error('Must be an array of minimum %d items', minLength)
    end

    if length(value) < minLength
        error('Must be an array of maximum %d items', maxLength)
    end
end

function str = PascalCase(str)
    str(1) = upper(str(1));
end