classdef (Abstract) SpecimenState < openminds.abstract.OpenMINDSSchema & core.category.FileOrigin

    properties (Access = private)
        Required = {}
    end

    properties
        % Enter additional remarks about the specimen (set) in this state.
        additionalRemarks (1,1) string

        % Add the age of the specimen (set) in this state.
        age (1,1) {openminds.core.QuantitativeValue, openminds.core.QuantitativeValueRange}

        % Enter a lookup label for this specimen (set) state that may help you to more easily find it again.
        lookupLabel (1,1) string

        % Add the pathology of the specimen (set) in this state.
        pathology (1,:) {openminds.controlledTerms.Disease, openminds.controlledTerms.DiseaseModel}

        % Add the weight of the specimen (set) in this state.
        weight (1,1) {openminds.core.QuantitativeValue, openminds.core.QuantitativeValueRange}
    end

    methods
        function obj = SpecimenState()
        end
    end

end