function setup(mode, options)
    
    arguments (Repeating)
        mode (1,1) string {mustBeMember(mode, ["force", "f", "update", "u", "savepath", "s"])};
    end

    arguments
        options.SavePathDef (1,1) logical = false 
    end

    mode = string(mode);

    if any(mode == "s") || any(mode == "savepath")
        options.SavePathDef = true;
        mode = setdiff(mode, ["s", "savepath"], 'stable');
    end

    % Assumes setup.m is located in root repository folder
    rootPath = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(rootPath, 'code')))
    addpath(genpath(fullfile(rootPath, 'devtools')))
    
    om.internal.setup.installRequirements(mode{:})

    run( fullfile(om.internal.rootpath, 'startup.m') )

    if options.SavePathDef
        savepath()
    end
end
