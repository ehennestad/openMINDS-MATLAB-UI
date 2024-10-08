classdef OpenMindsTheme < handle

    % Questions:
    % Should there be static methods to retrieve colors in different
    % formats? Or should it always be matlab centric, i.e 1x3 in [0,1]

    % Todo:
    %   [ ] Define different theme superclasses. I.e this is a 2+3 brand 
    %       theme. Or define primary and secondary colors as vectors?
    %   [ ] Add accent colors?

    properties (Constant)
        PrimaryColorA = hex2rgb( '#127e7a' )
        PrimaryColorB = hex2rgb( '#f7db2e' )
        PrimaryColorC = hex2rgb( '#82c558' ) % Light.
        SecondaryColorA = hex2rgb( '#2EB0FF' )
        SecondaryColorB = hex2rgb( '#5DC1FF' )
        SecondaryColorC = hex2rgb( '#FDF7FA' ) % Light.
    end
end
