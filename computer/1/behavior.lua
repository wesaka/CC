local currentChestDistance = 4 -- Starting distance to the first chest

while true do
    if redstone.getInput("right") then -- Assuming the right side of the turtle faces the computer
        turtle.forward() -- Move to the drop-off chest
        turtle.turnRight() -- Turn to face the drop-off chest
        turtle.select(2) -- Assuming slot 2 is for items (slot 1 is for extra chests)
        turtle.suck() -- Take items from the drop-off chest
        turtle.turnLeft() -- Turn to face the original direction
        
        -- Move to the current storage chest
        for i = 1, currentChestDistance do
            turtle.back()
        end
        
        -- Try to place items in the current storage chest
        turtle.turnRight() -- Turn to face the side of the chest
        if not turtle.drop() then -- Drop items into the side of the chest
            currentChestDistance = currentChestDistance + 1 -- Move to the next chest position (double chests are 2 blocks wide)
            turtle.forward() -- Move to the next chest position
            turtle.select(1) -- Select the chest slot
            turtle.placeDown() -- Place a new chest
            turtle.select(2) -- Select the item slot again
            turtle.drop() -- Drop items into the side of the new chest
        end
        turtle.turnLeft() -- Turn to face the original direction
        
        -- Return to the starting position
        for i = 2, currentChestDistance do
            turtle.forward()
        end
    end
    
    os.sleep(1) -- Check every second
end
