function setup(mode)
    
    arguments (Repeating)
        mode (1,1) string {mustBeMember(mode, ["force", "f", "update", "u"])};
    end
    
    addpath(genpath(fileparts(mfilename('fullpath'))))
    om.internal.setup.installRequirements(mode)

    run( fullfile(om.internal.rootpath, 'startup.m') )
end

%% test
