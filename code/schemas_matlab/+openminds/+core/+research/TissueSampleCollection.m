classdef TissueSampleCollection < openminds.core.research.SpecimenSet

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/TissueSampleCollection"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'origin', 'studiedState', 'type'}
    end

    properties
        % Add one or both hemisphere sides from which the tissue samples in this collection originate from.
        laterality (1,:) openminds.controlledTerms.Laterality {mustBeSpecifiedLength(laterality, 1, 2)}

        % Add the biogical origin (organ or cell type) of all tissue samples in this collection.
        origin (1,:) {openminds.controlledTerms.CellType, openminds.controlledTerms.Organ}

        % Add all states in which this tissue sample collection was studied.
        studiedState (1,:) openminds.core.TissueSampleCollectionState

        % Add the type of all tissue samples in this collection.
        type (1,:) openminds.controlledTerms.TissueSampleType
    end

    methods
        function obj = TissueSampleCollection()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end