StartupEvents.registry("block", (event) => {

    event.create('platinum_block')
        .displayName('Block of Platinum')
        .material('metal')
        .hardness(6)
        .tagBlock("mineable/pickaxe")
        .tagBlock('minecraft:needs_iron_tool')
        .requiresTool(true)
        

})

