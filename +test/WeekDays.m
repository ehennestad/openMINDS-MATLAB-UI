classdef WeekDays < openminds.controlledterms.ControlledTerm
   enumeration
      Monday('Monday'), Tuesday('Tuesday'), Wednesday('Wednesday'), Thursday('Thursday'), Friday('Friday')
   end

    properties (Constant, Hidden)
        X_TYPE = "https://openminds.ebrains.eu/controlledTerms/Species"
    end

    properties (SetAccess = immutable, Hidden)
        X_CATEGORIES = {'studyTarget'}
    end

    properties (Access = private)
        Required_ = {}
    end

   properties
       %name
       dayNumber
   end

   methods
       function obj = WeekDays(name)
            
           switch name
                case 'Monday'
                    obj.name = name;
                    obj.dayNumber = 1;
                case 'Tuesday'
                    obj.name = name;
                    obj.dayNumber = 2;
           end
            
       end
   end
end