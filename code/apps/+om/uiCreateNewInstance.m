function [metadataInstance, userData] = uiCreateNewInstance(instanceType, metadataCollection, options)
% uiCreateNewInstance - Open form dialog window for entering instance information
    
    % Todo: select structeditor based on matlab version / settings...

    arguments
        instanceType
        metadataCollection
        options.NumInstances = 1
    end

    userData = [];

    persistent formCache

    formCache = []; % During dev.

    if isempty(formCache)
        formCache = dictionary;
    end
    
    if isa(instanceType, 'char') || isa(instanceType, 'string')
        itemFactory = str2func(instanceType);
        metadataInstance = arrayfun(@(i)itemFactory(), 1:options.NumInstances);
    else
        metadataInstance = instanceType;
        instanceType = class(metadataInstance);
    end

    [SOrig, SNew] = deal( metadataInstance(1).toStruct() );

    SNew = om.convert.toStruct( metadataInstance, metadataCollection );
    
    % Fill out options for each property
    propNames = fieldnames(SOrig);

    % % for i = 1:numel(propNames)
    % %     iPropName = propNames{i};
    % %     iPropName_ = [iPropName, '_'];
    % %     iValue = SNew.(iPropName);
    % % 
    % %     if isenum(iValue)
    % %         [~, m] = enumeration( iValue );
    % %         SNew.(iPropName) = m{1};
    % %         SNew.(iPropName_) = m;
    % %     elseif isstring(iValue)
    % %         SNew.(iPropName) = char(iValue);
    % %     elseif isnumeric(iValue)
    % %         SNew.(iPropName) = double(iValue);
    % %     elseif isa(iValue, 'openminds.abstract.ControlledTerm')
    % %         m = eval( sprintf('%s.CONTROLLED_INSTANCES', class(iValue)));
    % %         %SNew.(iPropName) = char(m(1));
    % %         %SNew.(iPropName_) = cellstr(m);
    % % 
    % %         SNew.(iPropName) = categorical(m(1), m);
    % % 
    % %     elseif isa(iValue, 'openminds.abstract.Schema') && ...
    % %             ~isa(iValue, 'openminds.abstract.ControlledTerm')
    % % 
    % %         schemaLabels = metadataCollection.getSchemaInstanceLabels(class(iValue));
    % %         schemaShortName = openminds.MetadataCollection.getSchemaShortName(class(iValue));
    % % 
    % %         if isempty(schemaLabels)
    % %             valueOptions = {sprintf('No %s available', schemaShortName)};
    % %         else
    % %             valueOptions = [sprintf('Select a %s', schemaShortName), schemaLabels];
    % %         end
    % %         %SNew.(iPropName) = valueOptions{1};
    % %         %SNew.(iPropName_) = valueOptions;
    % %         SNew.(iPropName) = categorical(valueOptions(1), valueOptions);
    % % 
    % %     elseif isa(iValue, 'openminds.internal.abstract.LinkedCategory')
    % % 
    % %         SNew.(iPropName) = '';
    % %     else
    % %         warning('Values of type %s is not dealt with', class(iValue))
    % %     end
    % % end


    [~, ~, className] = fileparts(instanceType);
    [className, classNameLabel] = deal( className(2:end) );

    if options.NumInstances > 1; classNameLabel = [className, 's']; end

    titleStr = sprintf('Create New %s', classNameLabel);
    promptStr = sprintf('Fill out properties for %s', classNameLabel);
    %[SNew, wasAborted] = tools.editStruct(SNew, [], titleStr, 'Prompt', promptStr, 'Theme', 'light');
    

    if isConfigured(formCache) && isKey(formCache, className) && hasFigure(formCache(className))
        hEditor = formCache(className);
        hEditor.show();
        
        uiwait(hEditor, true)
        
        wasAborted = hEditor.FinishState ~= "Finished";
        SNew = hEditor.Data;
        hEditor.hide();
    else

        hEditor = structeditor.StructEditorApp(SNew, "Title", titleStr);
        hEditor.OkButtonText = 'Create';
    
        uiwait(hEditor, true)
        
        wasAborted = hEditor.FinishState ~= "Finished";
        SNew = hEditor.Data;
        hEditor.hide();
        formCache(className) = hEditor;
    end
    
    if wasAborted; return; end
        
    for i = 1:numel(propNames)
        iPropName = propNames{i};
        iValue = SOrig.(iPropName);

        if isenum(iValue)
            enumFcn = str2func( class(iValue) );
            SNew.(iPropName) = enumFcn(SNew.(iPropName));
        
        elseif isstring(iValue)
            SNew.(iPropName) = char(SNew.(iPropName));
        elseif isnumeric(iValue)
            SNew.(iPropName) = cast(SNew.(iPropName), class(metadataInstance.(iPropName)));
        elseif isa(iValue, 'openminds.abstract.ControlledTerm')
            SNew.(iPropName) = char(SNew.(iPropName));
        elseif isa(iValue, 'openminds.abstract.Schema')
            if isSchemaInstanceUnavailable(SNew.(iPropName)) % local function
                SNew.(iPropName) = SOrig.(iPropName);
            else
                label = SNew.(iPropName);
                schemaName = class(SOrig.(iPropName));
                schemaInstance = metadataCollection.getInstanceFromLabel(schemaName, label);
                SNew.(iPropName) = schemaInstance;
            end
        end
    end

    for i = 1:numel(metadataInstance)
        metadataInstance(i) = metadataInstance(i).fromStruct(SNew);
    end
    
    metadataCollection.add(metadataInstance)

    if ~nargout
        clear metadataInstance
    end

    if nargout < 2
        clear userData
    end
end


function tf = isSchemaInstanceUnavailable(value)
    tf = ~isempty(regexp(char(value), 'No \w* available', 'once'));
end
