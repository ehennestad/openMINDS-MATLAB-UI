classdef Model < openminds.core.products.ResearchProduct

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/Model"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'abstractionLevel', 'developer', 'scope', 'studyTarget'}
    end

    properties
        % Add the abstraction level of this model version.
        abstractionLevel (1,1) openminds.controlledTerms.ModelAbstractionLevel

        % Add one or several developers (person or organization) that contributed to the code implementation of this model.
        developer (1,:) {core.category.LegalPerson}

        % Add the globally unique and persistent digital identifier of this research product. Note that this digital identifier will be used to reference all attached research product versions.
        digitalIdentifier (1,1) {openminds.core.DOI, openminds.core.SWHID}

        % Add one or several versions of this computational model.
        hasVersion (1,:) openminds.core.ModelVersion

        % Add the scope of this model version.
        scope (1,1) openminds.controlledTerms.ModelScope

        % Add all study targets of this model version.
        studyTarget (1,:) {core.category.StudyTarget}
    end

    methods
        function obj = Model()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end