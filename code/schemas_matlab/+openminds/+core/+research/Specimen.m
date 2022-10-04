classdef (Abstract) Specimen < openminds.abstract.OpenMINDSSchema

    properties (Access = private)
        Required = {'biologicalSex', 'internalIdentifier', 'species'}
    end

    properties
        % Add the biological sex of this specimen.
        biologicalSex (1,1) openminds.controlledTerms.BiologicalSex

        % Enter the identifier of this specimen that is used within the corresponding data.
        internalIdentifier (1,1) string

        % Enter a lookup label for this specimen that may help you to more easily find it again.
        lookupLabel (1,1) string

        % Add the phenotype of this specimen.
        phenotype (1,1) openminds.controlledTerms.Phenotype

        % Add the species of this specimen.
        species (1,1) openminds.controlledTerms.Species

        % Add the strain of this specimen.
        strain (1,1) openminds.controlledTerms.Strain
    end

    methods
        function obj = Specimen()
        end
    end

end