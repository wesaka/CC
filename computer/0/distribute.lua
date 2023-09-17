-- distribute.lua
local ledgerFile = "ledger.txt"

-- Helper function to check if a chest has any free slots
function hasFreeSlot(chest)
    for slot = 1, chest.size() do
        if not chest.getItemDetail(slot) then
            return true
        end
    end
    return false
end

local mainChestName = "minecraft:chest_7"
local mainChest = peripheral.wrap(mainChestName)

local allPeripherals = peripheral.getNames()
local chests = {}

for _, name in pairs(allPeripherals) do
    if peripheral.getType(name) == "minecraft:chest" and name ~= mainChestName then
        table.insert(chests, peripheral.wrap(name))
    end
end

print("Found " .. #chests .. " chests to distribute items to.")

-- Serialize a table into a string
local function serialize(t)
    return textutils.serialize(t)
end

-- Deserialize a string into a table
local function deserialize(s)
    return textutils.unserialize(s)
end

-- Save the ledger to a file
local function saveLedger()
    local file = fs.open(ledgerFile, "w")
    file.write(serialize(ledger))
    file.close()
end

-- Load the ledger from a file
local function loadLedger()
    if fs.exists(ledgerFile) then
        local file = fs.open(ledgerFile, "r")
        local data = file.readAll()
        file.close()
        ledger = deserialize(data)
    else
        ledger = {}
    end
end

loadLedger()

function updateLedger(itemName, chestName, countChange)
    if not ledger[itemName] then
        ledger[itemName] = {}
    end
    if not ledger[itemName][chestName] then
        ledger[itemName][chestName] = 0
    end
    ledger[itemName][chestName] = ledger[itemName][chestName] + countChange

    -- Remove the chest entry if the count reaches 0
    if ledger[itemName][chestName] <= 0 then
        ledger[itemName][chestName] = nil
    end

    -- Remove the item entry if there are no chests containing it
    if not next(ledger[itemName]) then
        ledger[itemName] = nil
    end
end

for slot = 1, mainChest.size() do
    local item = mainChest.getItemDetail(slot)
    if item then
        print("Trying to distribute " .. item.count .. " of " .. item.name .. " from slot " .. slot)
        local transferred = false
        for _, chest in pairs(chests) do
            if hasFreeSlot(chest) then
                local count = ledger[item.name] and ledger[item.name][peripheral.getName(chest)] or 0
                local amount = math.min(item.count, 64 - count) -- 64 is the max stack size for most items
                if amount > 0 then
                    print("Pushing " .. amount .. " of " .. item.name .. " to " .. peripheral.getName(chest))
                    mainChest.pushItems(peripheral.getName(chest), slot, amount)
                    updateLedger(item.name, peripheral.getName(chest), amount)
                    item.count = item.count - amount
                    if item.count <= 0 then
                        transferred = true
                        break
                    end
                end
            end
        end

        if not transferred then
            for _, chest in pairs(chests) do
                if hasFreeSlot(chest) then
                    local amount = chest.pullItems(mainChestName, slot)
                    if amount > 0 then
                        print("Pulling " .. amount .. " of " .. item.name .. " to " .. peripheral.getName(chest))
                        updateLedger(item.name, peripheral.getName(chest), -amount) -- Decrease the count in the ledger
                        item.count = item.count - amount
                        if item.count <= 0 then
                            break
                        end
                    end
                end
            end
        end
    end
end

saveLedger()

print("Distribution complete!")