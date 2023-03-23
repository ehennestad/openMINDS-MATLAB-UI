classdef LinkedCategory < matlab.mixin.CustomCompactDisplayProvider & matlab.mixin.CustomDisplay & handle
%LinkedTypeSet Abstract class representing a set of linked types
    
    properties (Abstract, Constant)
        ALLOWED_TYPES
    end

    properties 
        Instance
    end
    
    % Todo: 
    % Redefine custom displays...
    % Redefine subsref and subsasgn??


    methods 
        function obj = LinkedCategory(instance)
            
            if nargin == 0; return; end

            if isempty(instance)
                obj(:) = [];
                return
            end

            if ~iscell(instance); instance = {instance}; end

            obj(numel(instance)) = feval(class(obj));

            for i = 1:numel(instance)
                
                if ischar(instance{i})
                    % Check if we can create a controlled instance from it
                    
                    for type = obj(i).ALLOWED_TYPES
                        if contains(type, 'openminds.controlledterms')
                            [e, m] = enumeration(type);
                    
                            if any( strcmp(instance{i}, m) )
                                instance{i} = e(strcmp(instance{i}, m));
                                break
                            end
                        end
                    end
                end

                mustBeOneOf(instance{i}, obj(i).ALLOWED_TYPES)
                obj(i).Instance = instance{i};
            end
        end
    end
    
    %CustomDisplay
    methods (Access = protected)
        function str = getHeader(obj)
            str = getHeader@matlab.mixin.CustomDisplay(obj);
            str = replace(str, ' with properties','');
            str = [newline, str]; %% Why is this needed some times?
        end

        function displayNonScalarObject(obj)
                
            repArray = arrayfun(@(o) o.Instance.compactRepresentationForSingleLine, obj, 'UniformOutput', false);
            %stringArray = cellfun(@(r) r.Representation, repArray);
            %rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', stringArray, 'Annotation', annotation');


            stringArray = cellfun(@(r) "    "+ r.PaddedDisplayOutput, repArray);
            stringArray = strrep(stringArray, '[', '');
            stringArray = strrep(stringArray, ']', '');
            str = obj.getHeader;
            disp(str)
            fprintf( '%s\n', strjoin(stringArray, '    \n') );
        end

    end
    
    methods % % CustomCompactDisplayProvider Method implementation
        
        function rep = compactRepresentationForSingleLine(obj, displayConfiguration, width)
            
            if nargin < 2
                displayConfiguration = matlab.display.DisplayConfiguration();
            end

            numObjects = numel(obj);
            
            %schemaName = obj.getSchemaShortName(class(obj));

            if isa(obj, 'openminds.controlledterms.ControlledTerm')
                annotation = 'Controlled Term';
            else
                allowedClasses = eval(sprintf('%s.ALLOWED_TYPES', class(obj)));
                annotation = arrayfun(@(s) getSchemaDocLink(s), allowedClasses, 'UniformOutput', false);
                annotation = strjoin(annotation, ', ');
            end

            if numObjects == 0
                str = 'None';
                %str = sprintf("Empty %s", schemaName);
                rep = matlab.display.PlainTextRepresentation(obj, str, displayConfiguration, 'Annotation', annotation);
                %rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', string(str));

            elseif numObjects == 1
                %rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', obj.DisplayString, 'Annotation', annotation);
                rep = obj.Instance.compactRepresentationForSingleLine;
                
                %rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', stringArray);


            else
                repArray = arrayfun(@(o) o.Instance.compactRepresentationForSingleLine, obj, 'UniformOutput', false);
                %stringArray = cellfun(@(r) r.Representation, repArray);
                %rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', stringArray, 'Annotation', annotation');


                stringArray = cellfun(@(r) r.PaddedDisplayOutput, repArray);
                stringArray = strrep(stringArray, '[', '');
                stringArray = strrep(stringArray, ']', '');

                rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', stringArray);
                %rep = compactRepresentationForSingleLine@matlab.mixin.CustomCompactDisplayProvider(obj, displayConfiguration, width);
            end
        end

        function rep = compactRepresentationForColumn(obj, displayConfiguration, default)
            
            %Note: Input will be an array with one object per row in the
            % column to represent. Output needs to take this into account.
            
            if nargin < 2
                displayConfiguration = matlab.display.DisplayConfiguration();
            end
            
            % Todo: Do this per row....
            numObjects = numel(obj);

            numRows = size(obj, 1);

            schemaName = obj.getSchemaShortName(class(obj));

            if numObjects == 0
                % str = 'None';
                str = sprintf('No %ss available', schemaName);
                rep = matlab.display.PlainTextRepresentation(obj, repmat({str}, numRows, 1), displayConfiguration);
            elseif numObjects >= 1 
                %str = obj.DisplayString;
                rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', arrayfun(@(i) obj(i).DisplayString, [1:numRows]', 'uni', 0) );

            elseif numObjects > 1
                %rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', obj.DisplayString );
                rep = compactRepresentationForColumn@matlab.mixin.CustomCompactDisplayProvider(obj, displayConfiguration, default);
            end
            
            % Fit all array elements in the available space, or else use
            % the array dimensions and class name
            % rep = fullDataRepresentation(obj, displayConfiguration, 'StringArray', str );
        end
        
    end

    methods (Static, Access = public, Hidden)
        
        function shortSchemaName = getSchemaShortName(fullSchemaName)
        %getSchemaShortName Get short schema name from full schema name
        % 
        %   shortSchemaName = getSchemaShortName(fullSchemaName)
        %
        %   Example:
        %   fullSchemaName = 'openminds.core.research.Subject';
        %   shortSchemaName = om.MetadataSet.getSchemaShortName(fullSchemaName)
        %   shortSchemaName =
        % 
        %     'Subject'

            expression = '(?<=\.)\w*$'; % Get every word after a . at the end of a string
            shortSchemaName = regexp(fullSchemaName, expression, 'match', 'once');
            if isempty(shortSchemaName)
                shortSchemaName = fullSchemaName;
            end
        end
    end
    
end