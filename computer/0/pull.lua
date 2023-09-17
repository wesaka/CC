-- pull.lua
local ledgerFile = "ledger.txt"

local targetItem, amountToPull = ...
amountToPull = tonumber(amountToPull)

if not targetItem or not amountToPull then
    print("Usage: pull <item_name> <amount>")
    return
end

local allPeripherals = peripheral.getNames()
local chests = {}

for _, name in pairs(allPeripherals) do
    if peripheral.getType(name) == "minecraft:chest" then
        table.insert(chests, peripheral.wrap(name))
    end
end

-- Set the main chest that is beside the computer
local mainChest = peripheral.wrap("minecraft:chest_7")

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

function findItemInChest(chest, targetItem)
    for slot = 1, chest.size() do
        local item = chest.getItemDetail(slot)
        if item and item.name == targetItem then
            return slot, item.count
        end
    end
    return nil
end

function updateLedger(itemName, chestName, count)
    if not ledger[itemName] then
        ledger[itemName] = {}
    end
    if not ledger[itemName][chestName] then
        ledger[itemName][chestName] = 0
    end
    ledger[itemName][chestName] = ledger[itemName][chestName] - count

    -- Remove the chest entry if the count reaches 0
    if ledger[itemName][chestName] <= 0 then
        ledger[itemName][chestName] = nil
    end

    -- Remove the item entry if there are no chests containing it
    if not next(ledger[itemName]) then
        ledger[itemName] = nil
    end
end


for _, chest in pairs(chests) do
    local chestName = peripheral.getName(chest)
    if ledger[targetItem] and ledger[targetItem][chestName] and ledger[targetItem][chestName] > 0 then
        print("Looking for " .. targetItem .. " in " .. chestName .. "...")
        local slot, count = findItemInChest(chest, targetItem)
        if slot then
            print("Found! Pulling items...")
            local amount = math.min(count, amountToPull)
            mainChest.pullItems(chestName, slot, amount)
            updateLedger(targetItem, chestName, amount)
            amountToPull = amountToPull - amount
            if amountToPull <= 0 then
                print("Pulled the desired amount of items. Exiting...")
                break
            end
        else
            print("Not found in " .. chestName .. ".")
        end
    end
end

if amountToPull > 0 then
    print("Couldn't find enough items. Still need: " .. amountToPull)
else
    print("Successfully pulled all requested items!")
end

saveLedger()