function mustBeTypeClassName(className)
% mustBeTypeClassName - Validator to check that a value is the class name 
% of an openminds metadata type

    arguments
        className (1,1) string
    end

    if ismissing(className); return; end

    [~, typeNames] = enumeration('openminds.enum.Types');
    if any(strcmp(className, typeNames))
        return
    end
    
    assert( startsWith(className, "openminds."), ...
        'Class name for openMINDS types must start with "openminds."' )
    
    mc = meta.class.fromName(className);

    assert( ~isempty(mc), '"%s" does not appear to be a class name. Please make sure openMINDS_MATLAB is added to the search path', className)

    isValid = any( strcmp({mc.SuperclassList.Name}, 'openminds.abstract.Schema') ) || ...
                any( strcmp({mc.SuperclassList.Name}, 'openminds.internal.abstract.LinkedCategory') );

    assert(isValid, "%s is not a valid class name for an openminds instance", className)
end