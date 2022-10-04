classdef TissueSample < openminds.core.research.Specimen

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/TissueSample"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'origin', 'studiedState', 'type'}
    end

    properties
        % Add all tissue sample collections of which this tissue sample is part of.
        isPartOf (1,:) openminds.core.TissueSampleCollection

        % Add one or both hemisphere sides from which this tissue sample originates from.
        laterality (1,:) openminds.controlledTerms.Laterality {mustBeSpecifiedLength(laterality, 1, 2)}

        % Add the biogical origin (organ or cell type) of this tissue sample.
        origin (1,1) {openminds.controlledTerms.CellType, openminds.controlledTerms.Organ}

        % Add all states in which this tissue sample was studied.
        studiedState (1,:) openminds.core.TissueSampleState

        % Add all anatomical entities to which this tissue sample belongs.
        anatomicalLocation (1,:) {openminds.controlledTerms.UBERONParcellation, openminds.sands.CustomAnatomicalEntity, openminds.sands.ParcellationEntity}

        % Add the type of this tissue sample.
        type (1,1) openminds.controlledTerms.TissueSampleType
    end

    methods
        function obj = TissueSample()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end