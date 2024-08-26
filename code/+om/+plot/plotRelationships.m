function plotRelationships(modelName)

    arguments
        modelName (1,1) om.enum.Models = "core"
    end
    
    G = om.generateGraph(lower(char(modelName)));
    om.internal.graphics.InteractiveOpenMINDSPlot(G)
end