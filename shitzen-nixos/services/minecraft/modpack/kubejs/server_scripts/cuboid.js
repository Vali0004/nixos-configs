/*
██╗  ██╗ █████╗ ██╗   ██╗███████╗███╗   ██╗    ███╗   ███╗ ██████╗ ██████╗ ██████╗  █████╗  ██████╗██╗  ██╗███████╗
██║  ██║██╔══██╗██║   ██║██╔════╝████╗  ██║    ████╗ ████║██╔═══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝
███████║███████║██║   ██║█████╗  ██╔██╗ ██║    ██╔████╔██║██║   ██║██║  ██║██████╔╝███████║██║     █████╔╝ ███████╗
██╔══██║██╔══██║╚██╗ ██╔╝██╔══╝  ██║╚██╗██║    ██║╚██╔╝██║██║   ██║██║  ██║██╔═══╝ ██╔══██║██║     ██╔═██╗ ╚════██║
██║  ██║██║  ██║ ╚████╔╝ ███████╗██║ ╚████║    ██║ ╚═╝ ██║╚██████╔╝██████╔╝██║     ██║  ██║╚██████╗██║  ██╗███████║
╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝    ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝
*/
ServerEvents.recipes(e => {
    let collapsingRecipe = (inputItem, inputCount, outputItem, outputCount) => {
        e.custom({
            type: "cuboidmod:collapsing",
            input: {
                item: inputItem,
                count: inputCount
            },
            result: {
                item: outputItem,
                count: outputCount
            }
        }).id(`cuboidmod:collapsing/${inputItem.replace(":", "_")}`)
    }
    let resourceGeneratingRecipe = (singularityItem, resultItem, workTimeMultiplier, outputMultiplier) => {
        e.custom({
            type: "cuboidmod:resource_generating",
            singularity: {
                item: singularityItem
            },
            result: {
                item: resultItem
            },
            work_time_multiplier: workTimeMultiplier,
            output_multiplier: outputMultiplier
        }).id(`cuboidmod:resource_generating/${singularityItem.replace(":", "_")}`)
    }
    
    // Item to Singularity - Input Item - Input Count - Output Item - Output Count
    collapsingRecipe("minecraft:calcite", 128, "cuboidmod:calcite_quantum_singularity", 1)
    collapsingRecipe("minecraft:tuff", 128, "cuboidmod:tuff_quantum_singularity", 1)
    collapsingRecipe("quark:jasper", 128, "cuboidmod:jasper_quantum_singularity", 1)
    
    // Singularity to Item - Result - Work Time Multiplier - Output Multiplier
    resourceGeneratingRecipe("cuboidmod:calcite_quantum_singularity", "minecraft:calcite", 2.0, 0.5)
    resourceGeneratingRecipe("cuboidmod:tuff_quantum_singularity", "minecraft:tuff", 2.0, 0.5)
    resourceGeneratingRecipe("cuboidmod:jasper_quantum_singularity", "quark:jasper", 2.0, 0.5)
})