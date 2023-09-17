-- consult.lua
local ledgerFile = "ledger.txt"

local targetItemPartial = ...

if not targetItemPartial then
    print("Usage: consult <partial_item_name>")
    return
end

-- Deserialize a string into a table
local function deserialize(s)
    return textutils.unserialize(s)
end

-- Load the ledger from a file
local function loadLedger()
    if fs.exists(ledgerFile) then
        local file = fs.open(ledgerFile, "r")
        local data = file.readAll()
        file.close()
        ledger = deserialize(data) or {}
    else
        ledger = {}
    end
end

loadLedger()

function findItemsInLedger(targetItemPartial)
    local results = {}
    for itemName, chestData in pairs(ledger) do
        if string.find(itemName, targetItemPartial) then
            for chestName, count in pairs(chestData) do
                if not results[itemName] then
                    results[itemName] = {}
                end
                results[itemName][chestName] = (results[itemName][chestName] or 0) + count
            end
        end
    end
    return results
end

local foundItems = findItemsInLedger(targetItemPartial)

for itemName, chestData in pairs(foundItems) do
    for chestName, count in pairs(chestData) do
        print(chestName .. " contains " .. count .. " of " .. itemName)
    end
end

if not next(foundItems) then
    print("No items matching '" .. targetItemPartial .. "' were found.")
end
