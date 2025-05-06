/*
██╗  ██╗ █████╗ ██╗   ██╗███████╗███╗   ██╗    ███╗   ███╗ ██████╗ ██████╗ ██████╗  █████╗  ██████╗██╗  ██╗███████╗
██║  ██║██╔══██╗██║   ██║██╔════╝████╗  ██║    ████╗ ████║██╔═══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝
███████║███████║██║   ██║█████╗  ██╔██╗ ██║    ██╔████╔██║██║   ██║██║  ██║██████╔╝███████║██║     █████╔╝ ███████╗
██╔══██║██╔══██║╚██╗ ██╔╝██╔══╝  ██║╚██╗██║    ██║╚██╔╝██║██║   ██║██║  ██║██╔═══╝ ██╔══██║██║     ██╔═██╗ ╚════██║
██║  ██║██║  ██║ ╚████╔╝ ███████╗██║ ╚████║    ██║ ╚═╝ ██║╚██████╔╝██████╔╝██║     ██║  ██║╚██████╗██║  ██╗███████║
╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝    ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝
*/
StartupEvents.registry('item', e => {
	e.create('cuboidmod:calcite_quantum_singularity')
        .displayName('Calcite Quantum Singularity')
        .textureJson({
            layer0: "kubejs:item/calcite_quantum_singularity",
            layer1: "kubejs:item/calcite_quantum_singularity_overlay"
        })

    e.create('cuboidmod:jasper_quantum_singularity')
        .displayName('Jasper Quantum Singularity')
        .textureJson({
            layer0: "kubejs:item/jasper_quantum_singularity",
            layer1: "kubejs:item/jasper_quantum_singularity_overlay"
        })

    e.create('cuboidmod:tuff_quantum_singularity')
        .displayName('Tuff Quantum Singularity')
        .textureJson({
            layer0: "kubejs:item/tuff_quantum_singularity",
            layer1: "kubejs:item/tuff_quantum_singularity_overlay"
        })        
})