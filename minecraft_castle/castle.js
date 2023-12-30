function buildWalls() {
    // Build the walls
    blocks.fill(
        blocks.block(Block.LogOak),
        pos(-4, 1, -4),
        pos(-4, 2, 4),
        FillOperation.Replace
    )
    blocks.fill(
        blocks.block(Block.LogOak),
        pos(4, 1, -4),
        pos(4, 2, 4),
        FillOperation.Replace
    )
    blocks.fill(
        blocks.block(Block.LogOak),
        pos(-3, 1, -4),
        pos(3, 2, -4),
        FillOperation.Replace
    )
    blocks.fill(
        blocks.block(Block.LogOak),
        pos(-3, 1, 4),
        pos(3, 2, 4),
        FillOperation.Replace
    )


    blocks.fill(
        blocks.block(Block.StoneBricks),
        pos(-4, 2, -4),
        pos(-4, 10, 4),
        FillOperation.Replace
    )
    blocks.fill(
        blocks.block(Block.StoneBricks),
        pos(4, 2, -4),
        pos(4, 10, 4),
        FillOperation.Replace
    )
    blocks.fill(
        blocks.block(Block.StoneBricks),
        pos(-3, 2, -4),
        pos(3, 10, -4),
        FillOperation.Replace
    )
    blocks.fill(
        blocks.block(Block.StoneBricks),
        pos(-3, 2, 4),
        pos(3, 10, 4),
        FillOperation.Replace
    )

    // Add a door
    blocks.fill(
        blocks.block(Block.Air),
        pos(0, 1, -4),
        pos(0, 2, -4),
        FillOperation.Replace
    )
    blocks.place(
        blocks.block(Block.DarkOakDoor),
        pos(0, 1, -4)
    )

    blocks.place(
        blocks.block(Block.Torch),
        pos(-1, 2, -5)
    )
    blocks.place(
        blocks.block(Block.Torch),
        pos(1, 2, -5)
    )

}

function buildWindow() {


    blocks.place(
        blocks.block(Block.Glass),
        pos(2, 2, -4)
    )

    blocks.place(
        blocks.block(Block.Glass),
        pos(-2, 2, -4)
    )

    blocks.place(
        blocks.block(Block.Glass),
        pos(2, 2, 4)
    )
    blocks.place(
        blocks.block(Block.Glass),
        pos(-2, 5, 4)
    )

    blocks.place(
        blocks.block(Block.Glass),
        pos(2, 8, 4)
    )



    blocks.fill(
        blocks.block(Block.Glass),
        pos(-1, 4, -4),
        pos(1, 8, -4),
        FillOperation.Replace
    )


}
function buildRoof() {
    // Build the roof
    blocks.fill(
        blocks.block(Block.PlanksDarkOak),
        pos(-5, 11, -5),
        pos(5, 11, 5),
        FillOperation.Replace
    )

    blocks.place(
        blocks.block(Block.PlanksDarkOak),
        pos(-5, 12, -5)
    )
    blocks.place(
        blocks.block(Block.PlanksDarkOak),
        pos(-5, 12, 5)
    )
    blocks.place(
        blocks.block(Block.PlanksDarkOak),
        pos(5, 12, -5)
    )
    blocks.place(
        blocks.block(Block.PlanksDarkOak),
        pos(5, 12, 5)
    )

    blocks.place(
        blocks.block(Block.PlanksDarkOak),
        pos(0, 12, 5)
    )
    blocks.place(
        blocks.block(Block.PlanksDarkOak),
        pos(5, 12, 0)
    )
    blocks.place(
        blocks.block(Block.PlanksDarkOak),
        pos(-5, 12, 0)
    )
    blocks.place(
        blocks.block(Block.PlanksDarkOak),
        pos(0, 12, -5)
    )


}


function buildBridge() {
    // Build the bridge
    blocks.fill(
        blocks.block(Block.PlanksOak),
        pos(-1, 0, -7),
        pos(1, 0, -8),
        FillOperation.Replace
    )
    blocks.fill(
        blocks.block(Block.PlanksOak),
        pos(-1, 0, -8),
        pos(1, 0, -9),
        FillOperation.Replace
    )

}

function buildMoat() {
    // Build the moat
    blocks.fill(
        blocks.block(Block.Water),
        pos(-9, -1, -9),
        pos(9, -1, 9),
        FillOperation.Replace
    )
    blocks.fill(
        blocks.block(Block.Air),
        pos(-8, -1, -8),
        pos(8, -1, 8),
        FillOperation.Replace
    )
}

function castleBase() {
    // Build the base of the house
    blocks.fill(
        blocks.block(Block.Stone),
        pos(-6, 0, -6),
        pos(6, 0, 6),
        FillOperation.Replace
    )


    blocks.fill(
        blocks.block(Block.Air),
        pos(-5, 1, -5),
        pos(5, 2, 5),
        FillOperation.Replace
    )
}

player.onChat("buildCastle", function () {
    player.teleport(pos(0, 0, 0))

    buildMoat();
    castleBase();
    buildWalls();
    buildWindow();
    buildRoof();
    buildBridge();

    player.teleport(pos(13, 1, 0))
})

player.runChatCommand("buildCastle")