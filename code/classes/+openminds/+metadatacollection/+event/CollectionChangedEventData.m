classdef CollectionChangedEventData < event.EventData

    properties
        EventType openminds.metadatacollection.event.CollectionChangedEventType
        Instances
        AffectedTypes
    end

    methods
        function obj = CollectionChangedEventData(eventType, instances)
            obj.EventType = eventType;
            obj.Instances = instances;
            obj.AffectedTypes = {};
        end
    end

end