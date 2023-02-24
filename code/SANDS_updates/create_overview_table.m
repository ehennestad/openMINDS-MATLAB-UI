% Acronyms
%  PE  : ParcellationEntity
%  PEV : ParcellationEntityVersion

% Todo: Partial matching on synonyms
%       Add PURL link to table columns

% Experiences:
%   Fuzzy search does not work very well.
%   Does word matching, count matching words, ignoring word order...

warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')

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
PEPropertyNames = ["alternativeName", "relatedUBERONTerm", "UBERONMatch", "UBERONSynonymMatch", "UBERONPartialMatch"];

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
  
% Get folder to load schema from:
thisPEInstanceDirectory = fullfile(PEInstanceRootDirectory, ATLAS_ACRONYM);

% Initialize table columns for Parcellation Entities
PEColumnTitles = PETableVariablePrefix + "_" + PEPropertyNames;
newTable{:, PEColumnTitles} = deal("");

% Fill out parcellation entity properties:

numRows = size(newTable, 1);

% Go through all rows in table
for iRow = 1:numRows
    thisEntityName = newTable{iRow, "WHSSD_PE_name"};
    thisEntityNameCamelCase = nameToCamelCase(thisEntityName);

    fprintf('Processing term %d/%d (%s)\n', iRow, numRows, thisEntityName)
    
    % Create filename for json instance:
    thisFilename = ATLAS_ACRONYM + "_" + thisEntityNameCamelCase + ".jsonld";
    thisFilepath = fullfile(thisPEInstanceDirectory, thisFilename);
        
    if isfile(thisFilepath)
        thisJsonObject = jsondecode( fileread(thisFilepath) );
        
        % Loop through property names
        for iPropName = 1:2%numel(PEPropertyNames)
            thisName = PEPropertyNames(iPropName);
            thisValue = getFormattedPropertyValue(thisJsonObject, thisName);

            thisColumnTitle = PEColumnTitles(iPropName);
            newTable{iRow, thisColumnTitle} = string(thisValue);
        end

        % Check if any UBERONParcellations match
        isMatch = strcmp({uberonInstances.Name}, thisEntityName );
        if any( isMatch )
            thisColumnTitle = PEColumnTitles(3);
            %newTable{iRow, thisColumnTitle} = string(uberonInstances(isMatch).Name);
            newTable{iRow, thisColumnTitle} = getHyperlink(uberonInstances(isMatch));
        end
        
        for i = 1:numel(uberonInstances)
            isMatch = strcmp(uberonInstances(i).Synonym, thisEntityName );
            if any(isMatch)
                %fprintf('%s: %s\n', thisEntityName, uberonInstances(i).Synonym{isMatch})
                newTable{iRow, PEColumnTitles(4)} = string(uberonInstances(i).Name);
            end
        end

        %bestMatchedUberonName = countMatchedWords(thisEntityName, uberonInstances);

% % %         % Check for partial matches for UBERONParcellations
% % %         uberonNames = {uberonInstances.Name};
% % %         [partialMatchedUberonNames, scores] = findPartialMatches(thisEntityName, uberonNames);
% % %         partialMatchScore = arrayfun(@num2str, scores, 'uni', 0);
% % %         partialMatchScore = strjoin(partialMatchScore, '; ');
% % % 
        %newTable{iRow, PEColumnTitles(5)} = string( bestMatchedUberonName );
% % %         newTable{iRow, PEColumnTitles(6)} = string( partialMatchScore );
    end
end

% Loop through versions
for iVersion = 1:numel(ATLAS_VERSIONS)

    % Initialize table columns for Parcellation Entity Versions
    PEVColumnTitles = PEVTableVariablePrefix(iVersion) + "_" + PEVPropertyNames;
    newTable{:, PEVColumnTitles} = deal("");

    % Get folder to load schema from:
    folderName = join( [ATLAS_ACRONYM, ATLAS_VERSIONS(iVersion) ], "_" );
    thisPEVInstanceDirectory = fullfile(PEVInstanceRootDirectory, folderName);
    
    for iRow = 1:numRows
        thisEntityName = newTable{iRow, "WHSSD_PE_name"};
        thisEntityNameCamelCase = nameToCamelCase(thisEntityName);
        
        % Create filename for json instance:
        thisFilename = folderName + "_" + thisEntityNameCamelCase + ".jsonld";
        thisFilepath = fullfile(thisPEVInstanceDirectory, thisFilename);
    
        if isfile(thisFilepath)
            thisJsonObject = jsondecode( fileread(thisFilepath) );

            % Loop through property names
            for iPropName = 1:numel(PEVPropertyNames)
                thisName = PEVPropertyNames(iPropName);
                thisValue = getFormattedPropertyValue(thisJsonObject, thisName);

                thisColumnTitle = PEVColumnTitles(iPropName);
                newTable{iRow, thisColumnTitle} = string(thisPropertyValue);
            end
        end
    end
end

outputFileName = sprintf( 'WHS_PE-PEV_update-%s.xlsx', datestr(now, 'yyyy_mm_dd_HHMMSS') );
outputFilepath = fullfile(workDirectory, outputFileName);
    
writetable(newTable, outputFilepath, "FileType", 'spreadsheet')

warning('on', 'MATLAB:table:ModifiedAndSavedVarnames')




function propertyValue = getFormattedPropertyValue(jsonObject, propertyName)
%getFormattedPropertyValue Get formatted value from json property
%
%   If the value is an array, turn into a semicolon separated list

    propertyValue = jsonObject.(propertyName);
    
    if isempty(propertyValue)
        propertyValue = ""; 
    elseif numel(propertyValue) > 1
        propertyValue = join(propertyValue, "; "); 
    end
end

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
        S(i).URL = thisJsonObject.preferredOntologyIdentifier;
    end

    uberonInstances = S;
end

function [partialMatchedUberonNames, scores] = findPartialMatches(thisEntityName, uberonNames)


        scores = zeros(numel(uberonNames), 1);
        for i = 1:numel(uberonNames)
            d = fzsearch( lower(uberonNames{i}), lower(char(thisEntityName)) );
            scores(i) = d(1);
        end

        minScore = min(scores);
        minScoreInd = find( scores == minScore );
        
        if numel(minScoreInd) > 1
            % Find best characterLengthMatch
            numChars = numel(char(thisEntityName));
            numCharsOthers = cellfun(@numel, uberonNames(minScoreInd));

            ratio = numChars ./ numCharsOthers;
            [~, bestRatioIdx] = min( abs( ratio-1 ) );

            bestIdx = minScoreInd(bestRatioIdx);
            partiallyMatchedUberon = uberonNames(bestIdx);
            scores = scores(bestIdx);
        else
            partiallyMatchedUberon = uberonNames(minScoreInd);
            scores = scores(minScoreInd);
        end

        partialMatchedUberonNames = strjoin(partiallyMatchedUberon, '; ');
        partialMatchedUberonNames = string(partialMatchedUberonNames);
       
        %[sorted, idx] = sort(scores);
        %table(sorted(1:30), uberonNames(idx(1:30))')

end

function bestMatchedUberonName = countMatchedWords(thisEntityName, uberonInstances)
    
    %matchedWordCountInstances = zeros(numel(uberonInstances), 1);
    S = struct;

    for i = 1:numel(uberonInstances)
        % Fractional match

        names = [{uberonInstances(i).Name}, uberonInstances(i).Synonym'];
        
        [fractionalMatchesA, fractionalMatchesB] = deal( zeros(1, numel(names)) );
        wordsInEntityName = strsplit(lower(thisEntityName), ' ');

        for j = 1:numel(names)
            [wordsInName, wordsInNameTmp] = deal(strsplit(lower(names{j}), ' '));
            count = 0;
            for k = 1:numel(wordsInEntityName)
                if any(strcmp(wordsInEntityName{k}, wordsInNameTmp))
                    wordsInNameTmp = setdiff(wordsInNameTmp, wordsInEntityName{k});
                    count = count+1;
                end
            end
            fractionalMatch = count / numel(wordsInEntityName);
            fractionalMatchesA(j) = count / numel(wordsInEntityName);
            fractionalMatchesB(j) = count / numel(wordsInName);
        end

        [topWordCount, bestIdx] = max(fractionalMatchesA);
        
        S(i).FractionalMatchA = topWordCount;
        S(i).FractionalMatchB = fractionalMatchesB(bestIdx);
        S(i).Name = names{bestIdx};
        S(i).IsSynonym = bestIdx ~= 1;
        
        % Find the highest count for this term. 
        % Store the count, the name and whether it is a synonym or the name
        
    end
    
    % Find the highest count overall
    [bestMatch, bestMatchIdx] = max([S.FractionalMatchA]);
    
    if bestMatch < 0.5 && S(bestMatchIdx).FractionalMatchB < 0.5
        bestMatchedUberonName = '';
    else 
        bestMatchedUberonName = S(bestMatchIdx).Name;
    end
    
end

function str = getHyperlink(uberonInstance)
    str = sprintf("=HYPERLINK(""%s""; ""%s"")", uberonInstance.URL, uberonInstance.Name);
end