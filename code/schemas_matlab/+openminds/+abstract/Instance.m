classdef Instance < handle
%INSTANCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Hidden)
        AT_CONTEXT = struct('x_vocab', 'https://openminds.ebrains.eu/vocab/');
    end

    properties (SetAccess = protected, Hidden)
        at_id
        at_type
    end

    methods

    end
end

