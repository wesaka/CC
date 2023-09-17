local args = {...} -- Get command-line arguments

function moveOrTurn(direction, steps)
    steps = steps or 1 -- Default to 1 step if not provided

    if direction == "left" then
        for i = 1, steps do
            turtle.turnLeft()
        end
    elseif direction == "right" then
        for i = 1, steps do
            turtle.turnRight()
        end
    elseif direction == "front" then
        for i = 1, steps do
            turtle.forward()
        end
    elseif direction == "back" then
        for i = 1, steps do
            turtle.back()
        end
    elseif direction == "up" then
        for i = 1, steps do
            turtle.up()
        end
    elseif direction == "down" then
        for i = 1, steps do
            turtle.down()
        end
    else
        print("Invalid direction!")
    end
end

-- Call the function using the provided arguments
if #args >= 1 then
    local direction = args[1]
    local steps = tonumber(args[2]) or 1
    moveOrTurn(direction, steps)
else
    print("Usage: movement <direction> [steps]")
end
