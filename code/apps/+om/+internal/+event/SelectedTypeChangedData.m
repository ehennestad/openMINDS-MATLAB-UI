classdef SelectedTypeChangedData < event.EventData
    % This class is for the event data of 'SelectedTypeChanged' events
        
    properties(SetAccess = 'private')
        SelectedType
    end
    
    methods
        function obj = SelectedTypeChangedData(selectedType)
            arguments
                selectedType (1,1) om.enum.Types
            end
            obj.SelectedType = selectedType;
        end
    end
end

