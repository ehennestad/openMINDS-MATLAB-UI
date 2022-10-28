classdef InteractiveOpenMINDSPlot < handle

    %
    % [ ] Mouseovereffects
    % [ ] Custom text labels
    % [ ] Node Doubleclick Action

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
    end

    methods 
        function obj = InteractiveOpenMINDSPlot(graphObj)
            
            obj.DirectedGraph = graphObj;

            obj.Axes = axes();
            obj.NodeTransporter = GraphNodeTransporter(obj.Axes);

            obj.GraphPlot = plot(obj.Axes, graphObj, 'Layout', 'force');
            obj.GraphPlot.ButtonDownFcn = @(s,e) obj.NodeTransporter.startDrag(s,e);

            obj.GraphPlot.MarkerSize = 20;

            colors = colormap(obj.ColorMap);
            numNodes = graphObj.numnodes;

            randIdx = randperm(256, numNodes);

            obj.GraphPlot.NodeColor = colors(randIdx, :);
            obj.GraphPlot.LineWidth = 1;
            obj.GraphPlot.EdgeColor = ones(1, 3)*0.6;
            
            hold(obj.Axes, 'on')
            obj.Axes.XLim = obj.Axes.XLim;
            obj.Axes.YLim = obj.Axes.YLim;
        end 
    end

end