% Acronyms
%  PE  : ParcellationEntity
%  PEV : ParcellationEntityVersion

% Todo: Partial matching on synonyms
%       Add PURL link to table columns


workDirectory = "/Users/eivinhen/Work/Nesys/openMINDS/Tasks/2023-02-07 - SANDS updates/";
openMindsDirectory = "/Users/eivinhen/Downloads/openMINDS-v3";

ATLAS_ACRONYM = "WHSSD";
ATLAS_VERSIONS = ["v4", "v3-01", "v3", "v2", "v1-01"];
SANDS_VERSION = "v3";

PEInstanceRootDirectory = fullfile(openMindsDirectory, "instances", ...
    "SANDS", SANDS_VERSION, "atlas", "parcellationEntity");

PEVInstanceRootDirectory = fullfile(openMindsDirectory, "instances", ...
    "SANDS", SANDS_VERSION, "atlas", "parcellationEntityVersion");

UBERONParcellationInstanceDirectory = fullfile(openMindsDirectory, ...
    "instances", "controlledTerms", "v1", "UBERONParcellation");
uberonInstances = readAllUBERONInstances(UBERONParcellationInstanceDirectory);

excelFileName = 'WHS_PE-PEV_update-2022-10-25.xlsx';

% Get all parcellation names from Ulrike's excel file
excelTable = readtable( fullfile(workDirectory, excelFileName));

% List property names to retrieve from parcellation
PETableVariablePrefix = join( [ATLAS_ACRONYM, "PE"], "_" );
PEPropertyNames = ["alternativeName", "relatedUBERONTerm"];

strExpand = @(str) repmat(str, size(ATLAS_VERSIONS) );
PEVTableVariablePrefix = join( [ strExpand(ATLAS_ACRONYM); ATLAS_VERSIONS; strExpand("PEV")], "_", 1 );
PEVTableVariablePrefix = replace(PEVTableVariablePrefix, '-', '_'); % make names valid for matlab table

PEVPropertyNames = ["name", "correctedName", "alternativeName", "additionalRemarks"];

% Make a copy of table to update from open MINDS
newTable = excelTable(:, 1:2);

% Convert all columns to strings
varNames = newTable.Properties.VariableNames;
for i = 2:size(newTable, 2)
    newTable.(varNames{i}) = string(newTable.(varNames{i}));
end
for i = 3:size(newTable, 2)
    newTable{:, varNames{i}} = "";
end


% Fill out parcellation entity properties:
    
% Get folder to load schema from:
thisPEInstanceDirectory = fullfile(PEInstanceRootDirectory, ATLAS_ACRONYM);

% Loop through property names
for iPropName = 1:numel(PEPropertyNames)
    thisPropName = PEPropertyNames(iPropName);
    
    for iRow = 1:size(newTable, 1)
        thisEntityName = newTable{iRow, 2};
        thisEntityNameCamelCase = nameToCamelCase(thisEntityName);
        
        % Create filename for json instance:
        thisFilename = ATLAS_ACRONYM + "_" + thisEntityNameCamelCase + ".jsonld";
        thisFilepath = fullfile(thisPEInstanceDirectory, thisFilename);
            
        if isfile(thisFilepath)

            thisJsonObject = jsondecode( fileread(thisFilepath) );
            thisPropertyValue = thisJsonObject.(thisPropName);
            
            if isfile(thisFilepath)

                thisJsonObject = jsondecode( fileread(thisFilepath) );
                thisPropertyValue = thisJsonObject.(thisPropName);

                if isempty(thisPropertyValue); thisPropertyValue = ""; end
                if numel(thisPropertyValue) > 1; thisPropertyValue = join(thisPropertyValue, "; "); end

                thisTableVariableName = PETableVariablePrefix + "_" + thisPropName;

                newTable{iRow, thisTableVariableName} = string(thisPropertyValue);
            end
        end

        % Check if any UBERONParcellations match
        isMatch = strcmp({uberonInstances.Name}, thisEntityName );
        if any( isMatch )
            thisTableVariableName = 'MatchedUberon';
            newTable{iRow, thisTableVariableName} = string(uberonInstances(isMatch).UberonID);
        end
        
        for i = 1:numel(uberonInstances)
            isMatch = strcmp(uberonInstances(i).Synonym, thisEntityName );
            if any(isMatch)
                fprintf('%s: %s\n', thisEntityName, uberonInstances(i).Synonym{isMatch})
                newTable{iRow, 'MatchedUberonSynonym'} = string(uberonInstances(i).UberonID);
            end
        end
    end 
end


% Loop through versions
for iVersion = 1:numel(ATLAS_VERSIONS)

    % Get folder to load schema from:
    folderName = join( [ATLAS_ACRONYM, ATLAS_VERSIONS(iVersion) ], "_" );
    thisPEVInstanceDirectory = fullfile(PEVInstanceRootDirectory, folderName);

    % Loop through property names
    for iPropName = 1:numel(PEVPropertyNames)
        thisPropName = PEVPropertyNames(iPropName);

        % Add table column
        thisTableVariableName = PEVTableVariablePrefix(iVersion) + "_" + thisPropName;
        newTable(:, thisTableVariableName) = table("");

        % Loop through ParcellationEntityNames
        for iPEName = 1:size(newTable, 1)
            thisEntityName = newTable{iPEName, 2};
            
            thisEntityNameCamelCase = nameToCamelCase(thisEntityName);

            % Create filename for json instance:
            thisFilename = folderName + "_" + thisEntityNameCamelCase + ".jsonld";
            thisFilepath = fullfile(thisPEVInstanceDirectory, thisFilename);

            if isfile(thisFilepath)

                thisJsonObject = jsondecode( fileread(thisFilepath) );
                thisPropertyValue = thisJsonObject.(thisPropName);

                if isempty(thisPropertyValue); thisPropertyValue = ""; end
                if numel(thisPropertyValue) > 1; thisPropertyValue = join(thisPropertyValue, "; "); end

                newTable{iPEName, thisTableVariableName} = string(thisPropertyValue);
            end
        end
    end
end

outputFileName = sprintf( 'WHS_PE-PEV_update-%s.xlsx', datestr(now, 'yyyy_mm_dd_HHMMSS') );
outputFilepath = fullfile(workDirectory, outputFileName);
    
writetable(newTable, outputFilepath, "FileType", 'spreadsheet')


function uberonInstances = readAllUBERONInstances(instanceDirectory)
    L = dir(instanceDirectory);
    L(strncmp({L.name}, '.', 1)) = [];
    S = struct;

    for i = 1:numel(L)
        thisJsonObject = jsondecode( fileread( fullfile(L(i).folder, L(i).name) ) );

        [~, id] = fileparts(thisJsonObject.x_id);
        [~, uberonId] = fileparts(thisJsonObject.preferredOntologyIdentifier);

        S(i).ID = id;
        S(i).Name = thisJsonObject.name;
        S(i).UberonID = uberonId;
        S(i).Synonym = thisJsonObject.synonym;
    end

    uberonInstances = S;
end
