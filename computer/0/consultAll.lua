-- consultAll.lua
local ledgerFile = "ledger.txt"
local totalsFile = "totals.txt"

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

local totalItems = {}

-- Calculate total count for each item
for itemName, chestData in pairs(ledger) do
    for _, count in pairs(chestData) do
        totalItems[itemName] = (totalItems[itemName] or 0) + count
    end
end

-- Save totals to a file
local function saveTotalsToFile()
    local file = fs.open(totalsFile, "w")
    for itemName, totalCount in pairs(totalItems) do
        file.writeLine(itemName .. ": " .. totalCount)
    end
    file.close()
end

saveTotalsToFile()

-- Display the total count for each item
for itemName, totalCount in pairs(totalItems) do
    print(itemName .. ": " .. totalCount)
end

if not next(totalItems) then
    print("No items found in the system.")
end
