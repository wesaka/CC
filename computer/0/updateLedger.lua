-- updateLedger.lua

local ledgerFile = "ledger.txt"

-- Initialize an empty ledger
ledger = {}

local allPeripherals = peripheral.getNames()
local chests = {}

for _, name in pairs(allPeripherals) do
    if peripheral.getType(name) == "minecraft:chest" then
        table.insert(chests, peripheral.wrap(name))
    end
end

print("Scanning " .. #chests .. " chests to update the ledger...")

-- Scan all chests and build the ledger
function buildLedger()
    for _, chest in pairs(chests) do
        for slot = 1, chest.size() do
            local item = chest.getItemDetail(slot)
            if item then
                if not ledger[item.name] then
                    ledger[item.name] = {}
                end
                if not ledger[item.name][peripheral.getName(chest)] then
                    ledger[item.name][peripheral.getName(chest)] = 0
                end
                ledger[item.name][peripheral.getName(chest)] = ledger[item.name][peripheral.getName(chest)] + item.count
            end
        end
    end
end

-- Serialize a table into a string
local function serialize(t)
    return textutils.serialize(t)
end
-- Save the ledger to a file
local function saveLedger()
    local file = fs.open(ledgerFile, "w")
    file.write(serialize(ledger))
    file.close()
end

buildLedger()
saveLedger()

print("Ledger updated successfully!")
