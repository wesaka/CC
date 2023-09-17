while true do
    local chest = peripheral.wrap("right") -- Replace "side" with the side the chest is on, e.g., "top", "right", etc.

    for i, item in pairs(chest.list()) do
        if item and item.name then
            print("Now moving " .. item.name)
            -- Send a redstone signal or message to the turtle to start moving items
            redstone.setOutput("back", true) -- Replace "side" with the side facing the turtle
            os.sleep(0.5) -- Wait for half a second
            redstone.setOutput("back", false)
            os.sleep(5) -- Wait for 5 seconds to give the turtle time to move items
        end
    end

    os.sleep(1) -- Check every second
end
