classdef TypeSelector < handle & matlab.mixin.SetGet
% TypeSelector Provides an abstract class for a component to select openMINDS types

    properties (SetAccess = immutable)
        % Types - A list of types to select from (options)
        Types (1,:) om.enum.Types
    end

    properties (AbortSet)
        % SelectedType - The currently selected type 
        SelectedType (1,1) om.enum.Types 
    end

    properties
        % SelectionChangedFcn - Function handle for function to call when a
        % type is selected. The function will receive to inputs, the source
        % of the interaction, i.e an object of this class, and an eventdata
        % object. See: om.internal.event.SelectedTypeChangedData
        SelectionChangedFcn
    end

    properties (Access = protected)
        Parent % Graphical parent container
    end
    
    properties (Abstract, Access = protected)
        UIComponent
    end
    
    % Constructor
    methods
        function obj = TypeSelector(hParent, options)
            arguments
                hParent = []
                options.?om.internal.abstract.TypeSelector
                options.Types (1,:) om.enum.Types
            end

            if isempty(hParent)
                obj.Parent = uifigure();
            else
                obj.Parent = hParent;
            end

            if isfield(options, 'Types')
                obj.Types = options.Types;
                obj.createComponent()
                options = rmfield(options, 'Types');
            end

            obj.set(options)

            if obj.SelectedType == "None" && ~isempty(obj.Types)
                obj.SelectedType = obj.Types(1);
            end
        end
    end

    methods (Abstract, Access = protected)
        createComponent(obj)
        
        % This method should update the selection in the component if the
        % component was updated programmatically, i.e when the SelectedType
        % property is set
        updateSelectedTypeInComponent(obj)

        % This is a callback method that should handle interaction events,
        % i.e when the selected type through user interactions with the
        % component
        onSelectedTypeChangedInComponent(obj)
    end

    % Public methods
    methods
    end
    
    % Set methods for properties
    methods
        function set.SelectedType(obj, value)
            value = obj.validateActiveType(value);
            obj.SelectedType = value;
            obj.postSetSelectedType()
        end
    end
    
    % Postset methods for properties
    methods (Access = private)
        function postSetSelectedType(obj)
            obj.updateSelectedTypeInComponent()
            if ~isempty(obj.SelectionChangedFcn)
                evtData = om.internal.event.SelectedTypeChangedData(obj.SelectedType);
                obj.SelectionChangedFcn(obj, evtData)
            end
        end
    end

    % Creation and internal updates
    methods (Access = private)

        function value = validateActiveType(obj, value)
        % validateActiveType - Validate value for ActiveType property

            isValid = any( obj.Types == value );
            
            errorMessage = sprintf( 'Selected type must be any of: %s', ...
                    strjoin(string(obj.Types), ', '));

            assert(isValid, errorMessage)
        end
    end
end