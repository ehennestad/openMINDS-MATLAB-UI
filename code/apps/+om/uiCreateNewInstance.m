function [metadataInstance, instanceName] = uiCreateNewInstance(instanceType, typeURI, metadataCollection, options)
% uiCreateNewInstance - Open form dialog window for entering instance information
    
    % Todo: select structeditor based on matlab version / settings...

    arguments
        instanceType
        typeURI % todo: use for creating dialog title
        metadataCollection
        options.NumInstances = 1
    end

    instanceName = string.empty;

    persistent formCache

    formCache = []; % During dev.

    if isempty(formCache)
        formCache = dictionary;
    end

    
    if isa(instanceType, 'char') || isa(instanceType, 'string')
        itemFactory = str2func(instanceType);
        metadataInstance = arrayfun(@(i) itemFactory(), 1:options.NumInstances);
    else
        if iscell(instanceType)
            metadataInstance = [instanceType{:}];
        else
            metadataInstance = instanceType;
        end
        instanceType = class(metadataInstance);
    end

    [SOrig, ~] = deal( metadataInstance(1).toStruct() );
    
    SNew = om.convert.toStruct( metadataInstance, metadataCollection );
    
    % Fill out options for each property
    propNames = fieldnames(SOrig);

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
        
        % Todo: Consider passing instances directly...
        %hEditor = structeditor.StructEditorApp(metadataInstance, "Title", titleStr, 'LoadingHtmlSource', om.internal.getSpinnerSource());

        hEditor = structeditor.StructEditorApp(SNew, ...
            "Title", titleStr, ...
            'LoadingHtmlSource', om.internal.getSpinnerSource(), ...
            'EnableNestedStruct', 'off' );

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
    instanceName = char(metadataInstance);

    if ~nargout
        clear metadataInstance
    end

    if nargout < 2
        clear instanceName
    end
end


function tf = isSchemaInstanceUnavailable(value)
    tf = ~isempty(regexp(char(value), 'No \w* available', 'once'));
end
