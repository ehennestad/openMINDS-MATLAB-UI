classdef SchemaTableColumnFormatter < nansen.metadata.abstract.TableVariable & nansen.metadata.abstract.TableColumnFormatter
    
    
    properties (Constant)
        IS_EDITABLE = false
        DEFAULT_VALUE = ''
    end

    methods

        function obj = SchemaTableColumnFormatter(S)
            if ~nargin; S = ''; end
            obj@nansen.metadata.abstract.TableVariable(S);
        end

        function str = getCellDisplayString(obj)

            if isenum(obj(1).Value)
                str = cellfun(@(c) char(c), {obj(:).Value}, 'UniformOutput', false);
            else
                str = class(obj(1).Value);
                str = repmat({str}, numel(obj), 1);
            end
        end

        function str = getCellTooltipString(obj)

            if isa(obj(1).Value, 'openminds.controlledterms.ControlledTerm')
            
            end
        end
    end

end