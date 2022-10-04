classdef DatasetVersion < openminds.core.products.ResearchProductVersion

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/DatasetVersion"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'digitalIdentifier', 'ethicsAssessment', 'experimentalApproach', 'license', 'technique', 'type'}
    end

    properties
        % If necessary, add one or several authors (person or organization) that contributed to the production and publication of this dataset version. Note that these authors will overwrite the once provided in the dataset product this version belongs to.
        author (1,:) {core.category.LegalPerson}

        % Add one or several behavioral tasks that were performed in this dataset version.
        behavioralTask (1,:) openminds.core.BehavioralTask

        % Add the globally unique and persistent digital identifier of this research product version.
        digitalIdentifier (1,1) openminds.core.DOI

        % Add the result of the ethics assessment of this dataset version.
        ethicsAssessment (1,1) openminds.controlledTerms.EthicsAssessment

        % Add all experimental approaches which this dataset version has deployed.
        experimentalApproach (1,:) openminds.controlledTerms.ExperimentalApproach

        % Add the data that was used as input for this dataset version.
        inputData (1,:) {openminds.core.DOI, openminds.core.File, openminds.core.FileBundle}

        % Add all dataset versions that can be used alternatively to this dataset version.
        isAlternativeVersionOf (1,:) openminds.core.DatasetVersion

        % Add the dataset version preceding this dataset version.
        isNewVersionOf (1,1) openminds.core.DatasetVersion

        % Add the license for this dataset version.
        license (1,1) openminds.core.License

        % Add one or several specimen (subjects and/or tissue samples) or specimen sets (subject groups and/or tissue sample collections) that were studied in this dataset.
        studiedSpecimen (1,:) {openminds.core.Subject, openminds.core.SubjectGroup, openminds.core.TissueSample, openminds.core.TissueSampleCollection}

        % Add one or several techniques that were used in this dataset version.
        technique (1,:) openminds.controlledTerms.Technique

        % Add all data types (raw, derived or simulated) provided in this dataset version.
        type (1,:) openminds.controlledTerms.SemanticDataType
    end

    methods
        function obj = DatasetVersion()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end