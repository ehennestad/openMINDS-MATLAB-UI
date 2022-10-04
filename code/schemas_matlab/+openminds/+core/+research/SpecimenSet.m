classdef (Abstract) SpecimenSet < openminds.abstract.OpenMINDSSchema

    properties (Access = private)
        Required = {'biologicalSex', 'species'}
    end

    properties
        % Enter additional remarks about the specimen set.
        additionalRemarks (1,1) string

        % Add the biological sex of all specimen in this set.
        biologicalSex (1,:) openminds.controlledTerms.BiologicalSex

        % Enter the identifier of this specimen set that is used within the corresponding data.
        internalIdentifier (1,1) string

        % Enter a lookup label for this specimen set that may help you to more easily find it again.
        lookupLabel (1,1) string

        % Add the phenotype of all specimen in this set.
        phenotype (1,:) openminds.controlledTerms.Phenotype

        % Enter the number of specimen that belong to this set.
        quantity (1,1) unit64

        % Add the species of all specimen in this set.
        species (1,:) openminds.controlledTerms.Species

        % Add the strain of all specimen in this set.
        strain (1,:) openminds.controlledTerms.Strain
    end

    methods
        function obj = SpecimenSet()
        end
    end

end