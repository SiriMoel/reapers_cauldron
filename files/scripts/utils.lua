dofile_once("data/scripts/lib/utilities.lua")

function flipbool(boolean) -- the real function flipbool()
    return not boolean
end

---@param bool boolean
---this is the greatest function of all time, it flips a boolean. true -> false and false -> true.
function flipboolean(bool) -- honestly quite incredible.
    if string.sub(tostring(bool), 1, 1) == "t" then
        bool = false
        return bool
    elseif string.sub(tostring(bool), 1, 1) == "f" then
        bool = true
        return bool
    end
end

function GetPlayer()
    local player = EntityGetWithTag("player_unit")[1]
    return player
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
        return true
    end
end
    return false
end

function SetFileContent(toset, content)
    ModTextFileSetContent(toset, ModTextFileGetContent("mods/souls/files/set/" .. content))
end

function IsInRadiusOf(xa, ya, xb, yb, radius) -- i dont think this works, isnt needed anyway.
    if xa - xb < radius and ya - yb < radius then
        return true
    end
    return false
end

---@param entity_id integer
---@param material_name string
---@return number
function GetAmountOfMaterialInInventory(entity_id, material_name) -- stolen from https://github.com/Priskip/purgatory
    local amount = 0
    local mat_inv_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialInventoryComponent") or 0
    local count_per_material_type = ComponentGetValue2(mat_inv_comp, "count_per_material_type")

    for i,v in ipairs(count_per_material_type) do
        if v ~= 0 then
            if CellFactory_GetName(i - 1) == material_name then
                amount = v
            end
        end
    end

    return amount
end

function GetMoney()
    local player = EntityGetWithTag("player_unit")[1]
    local comp_wallet = EntityGetFirstComponentIncludingDisabled(player, "WalletComponent") or 0
    local money = ComponentGetValue2(comp_wallet, "money")
    return money
end

function SetMoney(amount)
    local player = EntityGetWithTag("player_unit")[1]
    local comp_wallet = EntityGetFirstComponentIncludingDisabled(player, "WalletComponent") or 0
    ComponentSetValue2(comp_wallet, "money", amount)
end

function CanAfford(amount)
    local player = EntityGetWithTag("player_unit")[1]
    local comp_wallet = EntityGetFirstComponentIncludingDisabled(player, "WalletComponent") or 0
    local money = ComponentGetValue2(comp_wallet, "money")
    if money >= amount then
        return true
    else
        return false
    end
end

---@param spent boolean if the player's money_spent should be increased.
-- usage: if ReduceMoney(100, true) then EntityLoad("thing", x, y) end
function ReduceMoney(amount, spent)
    local player = EntityGetWithTag("player_unit")[1]
    local comp_wallet = EntityGetFirstComponentIncludingDisabled(player, "WalletComponent") or 0
    local money = ComponentGetValue2(comp_wallet, "money")
    local moneyspent = ComponentGetValue2(comp_wallet, "money_spent")
    if CanAfford(amount) == false then
        GamePrint("You cannot afford that.")
        return false
    end
    money = money - amount
    ComponentSetValue2(comp_wallet, "money", money)
    if spent == true then
        moneyspent = moneyspent + amount
        ComponentSetValue2(comp_wallet, "money_spent", moneyspent)
    end
    return true
end

function AddMoney(amount)
    local player = EntityGetWithTag("player_unit")[1]
    local comp_wallet = EntityGetFirstComponentIncludingDisabled(player, "WalletComponent") or 0
    local money = ComponentGetValue2(comp_wallet, "money")
    money = money + amount
    ComponentSetValue2(comp_wallet, "money", money)
end

function CurrentCard(wand) -- version of copi code that makes my brain happy
    local wand_actions = EntityGetAllChildren(wand) or {}
    for i=1,#wand_actions do
        local itemcomp = EntityGetFirstComponentIncludingDisabled(wand_actions[i], "ItemComponent")
        if itemcomp then
            if ComponentGetValue2(itemcomp,"mItemUid") == current_action.inventoryitem_id then
                return wand_actions[i]
            end
        end
    end
end

function HeldItem(player)
    local comp_inv = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component") or 0
    local held_item = ComponentGetValue2(comp_inv, "mActiveItem")
    return held_item
end

function IncreaseFlightLeft(player, amount)
    local comp = EntityGetFirstComponent( player, "CharacterDataComponent" )
    if comp ~= nil then
        local flight = ComponentGetValue2( comp, "mFlyingTimeLeft" )
		local maxflight = ComponentGetValue2( comp, "fly_time_max" ) or 3.0
        flight = math.min( maxflight, flight + amount )
        ComponentSetValue2( comp, "mFlyingTimeLeft", flight )
    end
end

function PickRandomFromTableWeighted(x, y, table) -- i stole from utilities.lua
    if #table == 0 then return nil end
    math.randomseed(x, y)
    local weight_sum = 0.0
    for i,v in ipairs(table) do
        v.weight_min = weight_sum
        v.weight_max = weight_sum + v.probability
        weight_sum = v.weight_max
    end
    local val = ProceduralRandomf(x, y, 0.0, weight_sum )
    local result = table[1]
    for i,v in ipairs(table) do
        if val >= v.weight_min and val <= v.weight_max then
            result = v
            break
        end
    end
    return result
end

function EntityKillAllWithTag(tag)
    local targets = EntityGetWithTag(tag)
    for i,target in ipairs(targets) do
        EntityKill(target)
    end
end

function DistanceBetween(x1, y1, x2, y2)
    return math.sqrt(((x2 - x1)^2) + ((y2 - y1)^2))
end


function string.scramble(s) -- danke https://stackoverflow.com/questions/51752497/how-to-shuffle-the-letters-of-a-word-using-lua
    local frame = GameGetFrameNum()
    math.randomseed(frame, frame)
    local letters = {}
    for letter in s:gmatch'.[\128-\191]*' do
       table.insert(letters, {letter = letter, rnd = math.random()})
    end
    table.sort(letters, function(a, b) return a.rnd < b.rnd end)
    for i, v in ipairs(letters) do letters[i] = v.letter end
    return table.concat(letters)
end

function AnyOfTableEquals(table, what)
    for i=1,#table do
        if table[i] == what then
            return true
        end
    end
    return false
end

function AmountOfTableEquals(table, what)
    local amount = 0
    for i=1,#table do
        if table[i] == what then
            amount = amount + 1
        end
    end
    return amount
end