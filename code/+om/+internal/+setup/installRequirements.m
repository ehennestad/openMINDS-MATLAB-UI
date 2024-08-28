function installRequirements(options)

    arguments
        % Tentative, not implemented yet!
        options.UseDefaultInstallationLocation (1,1) logical = true
        options.UpdateSearchPath (1,1) logical = true
    end

    reqs = om.internal.setup.getRequirements();
    
    installationLocation = om.internal.constant.AddonTargetFolder();
    if ~isfolder(installationLocation); mkdir(installationLocation); end

    for i = 1:numel(reqs)
        switch reqs(i).Type
            case 'GitHub'
                om.internal.setup.installGithubRepository( reqs(i).URI )
            case 'FileExchange'
                [packageUuid, version] = getFEXPackageSpecification( reqs(i).URI );
                om.internal.setup.installFexPackage(packageUuid, installationLocation, 'Version', version);

            case 'Unknown'
                continue
        end        
    end
end

function [packageUuid, version] = getFEXPackageSpecification(uri)
% getFEXPackageSpecification - Get UUID and version for package
%
%   NB: This function relies on an undocumented api, and might break in the
%   future.

    version = "latest"; % Initialize default value

    FEX_API_URL = "https://addons.mathworks.com/registry/v1/";
    
    splitUri = strsplit(uri, '/');

    packageNumber = regexp(splitUri{2}, '\d*(?=-)', 'match', 'once');
    try
        packageInfo = webread(FEX_API_URL + num2str(packageNumber));
        packageUuid = packageInfo.uuid;
    catch ME
        switch ME.identifier
            case 'MATLAB:webservices:HTTP404StatusCodeError'
                error('FEX package with identifier "%s" was not found', splitUri{2})
            otherwise
                rethrow(ME)
        end
    end

    if numel(splitUri) == 3
        version = string( splitUri{3} );
        assert( any(strcmp(packageInfo.versions, version) ), ...
            'Specified version "%s" is not supported for FEX package "%s"', ...
            version, splitUri{2});
    end
end