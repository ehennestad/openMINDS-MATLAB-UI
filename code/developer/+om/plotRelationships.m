function plotRelationships(modelName)

    arguments
        modelName (1,1) om.enum.Models = "core"
    end
    
    G = om.generateGraph(lower(char(modelName)));
    InteractiveOpenMINDSPlot(G)
end