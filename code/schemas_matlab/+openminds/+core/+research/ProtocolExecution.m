classdef ProtocolExecution < openminds.core.research.Activity

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/core/ProtocolExecution"
    end

    properties (SetAccess = immutable)
        X_CATEGORIES = {}
    end

    properties (SetAccess = immutable)
        Required = {'input', 'isPartOf', 'output', 'protocol'}
    end

    properties
        % Add all behavioral tasks that were performed during this protocol execution.
        behavioralTask (1,:) openminds.core.BehavioralTask

        % N/A
        input (1,1) {openminds.core.File, openminds.core.FileBundle, openminds.core.SubjectGroupState, openminds.core.SubjectState, openminds.core.TissueSampleCollectionState, openminds.core.TissueSampleState}

        % Add the dataset version in which this protocol execution was conducted.
        isPartOf (1,1) openminds.core.DatasetVersion

        % N/A
        output (1,1) {openminds.core.File, openminds.core.FileBundle, openminds.core.SubjectGroupState, openminds.core.SubjectState, openminds.core.TissueSampleCollectionState, openminds.core.TissueSampleState}

        % Add the initial preparation type for this protocol execution.
        preparationType (1,1) openminds.controlledTerms.PreparationType

        % Add all protocols that were used in this protocol execution.
        protocol (1,:) openminds.core.Protocol
    end

    methods
        function obj = ProtocolExecution()
            required = obj.getSuperClassRequiredProperties();
            obj.Required = [required, obj.Required];

        end
    end

end