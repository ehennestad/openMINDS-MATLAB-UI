classdef Constants < handle

    properties (Constant)
        GithubURL    = "https://github.com/HumanBrainProject/openMINDS"
        SchemaURL    = om.Constants.GithubURL + "/raw/documentation/openMINDS-v3.zip"
        VocabURL     = om.Constants.GithubURL + "/raw/main/vocab"
        LogoLightURL = om.Constants.GithubURL + "/raw/main/img/light_openMINDS-logo.png";
        LogoDarkURL  = om.Constants.GithubURL + "/raw/main/img/dark_openMINDS-logo.png";
        SchemaFolder = fullfile(om.Constants.getRootPath(), 'schemas')
    end

    methods (Static)
        function thisPath = getRootPath()
            thisPath = fileparts(mfilename("fullpath"));
            splitIdx = regexp(thisPath, 'openMINDS-MATLAB', 'end');

            thisPath = thisPath(1:splitIdx(end));
        end
    end
end

