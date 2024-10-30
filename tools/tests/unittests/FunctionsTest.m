classdef FunctionsTest < matlab.unittest.TestCase

    methods(TestClassSetup)
        % Shared setup for the entire test class
    end
    
    methods(TestMethodSetup)
        % Setup for each test
    end
    
    methods(Test)

        function testpathstr2packagename(testCase)
            pathStr = '/Users/Eivind/Code/MATLAB/Neuroscience/Repositories/ehennestad/openMINDS-MATLAB-UI/code/+om/+internal/+strutil';
            packageName = om.internal.strutil.pathstr2packagename(pathStr);
            testCase.verifyEqual(string(packageName),"om.internal.strutil")
        end
    end
end