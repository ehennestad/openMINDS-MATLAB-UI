classdef InteractiveOpenMINDSPlot < handle

    %
    % [ ] Mouseover effects. Hand, magnify node and label
    % [ ] Custom text labels
    % [ ] Node Doubleclick Action
    % [ ] Add methods for plotting subgraps? Or should that be a separate
    %     panel in the main app for plotting subgraphs?

    properties
         ColorMap = 'viridis'
         ShowNodeLabels
         ShowEdgeLabels
    end

    properties (Access = protected) % data
        DirectedGraph
    end
   
    properties (Access = protected) % grahical
        Axes
        GraphPlot
        NodeTransporter
        PointerManager
    end

    methods 
        function obj = InteractiveOpenMINDSPlot(graphObj, hAxes, e)
            
            obj.DirectedGraph = graphObj;

            if nargin >= 2
                obj.Axes = hAxes;
            else
                obj.Axes = axes();
            end

            obj.GraphPlot = plot(obj.Axes, graphObj, 'Layout', 'force');

            numNodes = graphObj.numnodes;
            colors = colormap(obj.ColorMap);
            randIdx = randperm(256, numNodes);
            obj.GraphPlot.NodeColor = colors(randIdx, :);
            
            obj.GraphPlot.MarkerSize = 20;
            obj.GraphPlot.LineWidth = 1;
            obj.GraphPlot.EdgeColor = ones(1, 3)*0.6;
            
            hold(obj.Axes, 'on')
            obj.Axes.XLim = obj.Axes.XLim;
            obj.Axes.YLim = obj.Axes.YLim;
            %obj.Axes.Units = 'pixel';

            obj.GraphPlot.NodeFontName = 'avenir';
            obj.GraphPlot.NodeFontSize = 10;
            obj.GraphPlot.NodeLabelColor = [0.2,0.2,0.2];
            
            obj.NodeTransporter = GraphNodeTransporter(obj.Axes);
            obj.GraphPlot.ButtonDownFcn = @(s,e) obj.NodeTransporter.startDrag(s,e);

            %obj.GraphPlot.EdgeLabel = e;
    
            obj.Axes.YDir = 'normal';
            hFigure = ancestor(hAxes, 'figure');
            obj.PointerManager = uim.interface.pointerManager(hFigure, ...
                obj.Axes, {'zoomIn', 'zoomOut', 'pan'});
            addlistener(hFigure, 'WindowKeyPress', @obj.keyPress);
            
            %obj.Axes.YDir = 'reverse';
        end 


        function keyPress(obj, src, event)
            wasCaptured = obj.PointerManager.onKeyPress([], event);
        end

    end

end