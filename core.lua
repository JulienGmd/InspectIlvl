-- Arrow indicator on items in bags if ilvl is an upgrade

--TODO rajouter CanEquipItem (semble pas checker si war peut equiper maille)
-- classArmorType et itemInventoryType
-- local itemInventoryType = GetItemInventoryType(itemID)
-- local _, _, _, classArmorType = GetClassInfo(classID)

-- After a bag is oppened or an item was moved in a bag
EventRegistry:RegisterCallback("ItemButton.UpdateItemContextMatching", function(event, bagId)
  if IsCombinedBag() then

    -- Blizzard's combined bags
    -- All bags are oppened, so check all items of all bags
    for bagId = 0, 4 do -- Ignore the last bag (reagents)
      local numSlots = C_Container.GetContainerNumSlots(bagId)
      for slotId = 1, numSlots do
        local itemFrameId = numSlots - slotId + 1 -- Because the item frames are in reverse order
        local itemFrame = _G["ContainerFrame" .. bagId + 1 .. "Item" .. itemFrameId]
        local itemLink = C_Container.GetContainerItemLink(bagId, slotId)
        if IsILvlUpgrade(itemLink) then
          ShowArrowTexture(itemFrame)
        else
          HideArrowTexture(itemFrame)
        end
      end
    end

  else

    -- Blizzard's bags
    -- The event is called for a specific bag, check all items of this bag
    if bagId == 5 then return end -- Ignore the last bag (reagents)
    -- Here bagFrameId can't be deduced from the bagId,
    -- because bagFrameId depends on the order we open the bags
    local bagFrameId = GetBagFrameId(bagId)
    -- If the bag is not oppened, do nothing
    -- Can happen sometimes after leaving an instance with a bag oppened
    if not bagFrameId then return end
    local numSlots = C_Container.GetContainerNumSlots(bagId)
    for slotId = 1, numSlots do
      local itemFrameId = numSlots - slotId + 1 -- Because the item frames are in reverse order
      local itemFrame = _G["ContainerFrame" .. bagFrameId .. "Item" .. itemFrameId]
      local itemLink = C_Container.GetContainerItemLink(bagId, slotId)
      if IsILvlUpgrade(itemLink) then
        ShowArrowTexture(itemFrame)
      else
        HideArrowTexture(itemFrame)
      end
    end

  end
end)


function IsCombinedBag()
  return _G["ContainerFrameCombinedBags"]:IsShown()
end

-- Returns:
-- true if the item can be equipped and the item ilvl is greater than the currently equipped item ilvl
-- false otherwise
function IsILvlUpgrade(itemLink)
  if not itemLink then return false end

  local invSlotId = GetInvSlotId(itemLink)
  if invSlotId and invSlotId >= 1 and invSlotId <= 18 then -- If armor or weapon

    local equippedItemLink = GetInventoryItemLink("player", invSlotId)
    if not equippedItemLink then return true end -- If no item is equipped, then the item is an upgrade

    local itemLevel = GetDetailedItemLevelInfo(itemLink)
    local equippedItemLevel = GetEquippedItemLevel(invSlotId)

    -- If ring, trinket or weapon, check both slots
    if invSlotId == 11 or invSlotId == 13 or (invSlotId == 16 and Can16BeEquippedIn17(itemLink)) then
      local equippedItemLevel2 = GetEquippedItemLevel(invSlotId + 1)
      if equippedItemLevel2 < equippedItemLevel then
        equippedItemLink = GetInventoryItemLink("player", invSlotId + 1)
        equippedItemLevel = equippedItemLevel2
      end
    end

    if itemLevel > equippedItemLevel then
      return true
    end
  end
  return false
end

-- Should be used without combined bags
-- Returns the bag frame id (1 to 6)
function GetBagFrameId(bagId)
  for bagFrameId = 1, 6 do
    local bagFrame = _G["ContainerFrame" .. bagFrameId]
    -- Check if this bag frame id is equal to input param bagId
    -- Because when opening a bag, the same bag can be ContainerFrame1 or 2 or 3 or 4 or 5 or 6
    -- depending on the order you open the bags
    if bagFrame:IsShown() and bagFrame:GetBagID() == bagId then
      return bagFrameId
    end
  end
  return nil
end

-- Returns the item level of the equipped item in invSlotId
function GetEquippedItemLevel(invSlotId)
  local itemLink = GetInventoryItemLink("player", invSlotId)
  if itemLink then
    local itemLevel = GetDetailedItemLevelInfo(itemLink)
    return itemLevel
  end
  return 0
end

local invSlotIds = {
  INVTYPE_HEAD = 1,
  INVTYPE_NECK = 2,
  INVTYPE_SHOULDER = 3,
  INVTYPE_BODY = 4,
  INVTYPE_CHEST = 5,
  INVTYPE_ROBE = 5,
  INVTYPE_WAIST = 6,
  INVTYPE_LEGS = 7,
  INVTYPE_FEET = 8,
  INVTYPE_WRIST = 9,
  INVTYPE_HAND = 10,
  INVTYPE_FINGER = 11,
  INVTYPE_TRINKET = 13,
  INVTYPE_CLOAK = 15,
  INVTYPE_WEAPON = 16,
  INVTYPE_WEAPONMAINHAND = 16,
  INVTYPE_2HWEAPON = 16,
  INVTYPE_RANGED = 16,
  INVTYPE_RANGEDRIGHT = 16,
  INVTYPE_THROWN = 16,
  INVTYPE_RELIC = 16,
  INVTYPE_SHIELD = 17,
  INVTYPE_WEAPONOFFHAND = 17,
  INVTYPE_HOLDABLE = 17,
}

-- Returns the inventory slot id where the item can be equipped (1 to 18)
-- Ring, trinket and weapon always returns 11, 13 and 16 (because there are 2 slots)
function GetInvSlotId(itemLink)
  local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
  if invSlotIds[itemEquipLoc] then
    return invSlotIds[itemEquipLoc]
  end
  return nil
end

function Can16BeEquippedIn17(itemLink)
  -- Must be one-handed weapon
  local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
  if itemEquipLoc ~= "INVTYPE_WEAPONMAINHAND" or itemEquipLoc ~= "INVTYPE_WEAPON" then
    return false
  end

  -- A shield must not be equipped
  local itemLink17 = GetInventoryItemLink("player", 17)
  if itemLink17 then
    local _, _, _, _, _, _, _, _, itemEquipLoc17 = GetItemInfo(itemLink17)
    if itemEquipLoc17 == "INVTYPE_SHIELD" then
      return false
    end
  end

  -- 2H or ranged must not be equipped
  local itemLink16 = GetInventoryItemLink("player", 16)
  if itemLink16 then
    local _, _, _, _, _, _, _, _, itemEquipLoc16 = GetItemInfo(itemLink16)
    if itemEquipLoc16 == "INVTYPE_2HWEAPON" or
        itemEquipLoc16 == "INVTYPE_RANGED" or
        itemEquipLoc16 == "INVTYPE_RANGEDRIGHT" then
      return false
    end
  end

  return true
end

-- Show or create the arrow texture
function ShowArrowTexture(itemFrame)
  if itemFrame["ILvlUpgradeTex"] then
    itemFrame["ILvlUpgradeTex"]:Show()
  else
    itemFrame["ILvlUpgradeTex"] = itemFrame:CreateTexture(nil, "OVERLAY")
    itemFrame["ILvlUpgradeTex"]:SetTexture("Interface\\MINIMAP\\MiniMap-QuestArrow")
    itemFrame["ILvlUpgradeTex"]:SetPoint("TOPRIGHT", itemFrame, "TOPRIGHT", 6, 4)
    itemFrame["ILvlUpgradeTex"]:SetSize(26, 26)
  end
end

function HideArrowTexture(itemFrame)
  if itemFrame["ILvlUpgradeTex"] then
    itemFrame["ILvlUpgradeTex"]:Hide()
  end
end

--[[ -- Adibags support

--TODO update à l'ouverture du sac (la ca update à chaque fois qu'un item bouge)
--TODO marche pas
EventRegistry:RegisterCallback("AdiBags_BagOpened", function(event, ...)
  print("AdiBags_BagOpened")
  UpdateAdiBagsItems()
end)

-- When an item has changed in a bag
local function OnEvent(self, event, ...)
  if event == "BAG_UPDATE" then
    UpdateAdiBagsItems()
  end
end

function UpdateAdiBagsItems()
  -- Check if Adibags frame exists
  if not _G["AdiBagsContainer1"] then return end

  -- Loop through all Adibags item frames
  local i = 0
  while true do
    local itemContainer = _G["AdiBagsItemContainer" .. i]
    if not itemContainer then break end

    local children = { itemContainer:GetChildren() }
    for _, child in ipairs(children) do
      if child:IsShown() then
        local itemLink = child:GetItemLink()
        if IsILvlUpgrade(itemLink) then
          ShowArrowTexture(child)
        else
          HideArrowTexture(child)
        end
      end
    end
    i = i + 1
  end
end

local f = CreateFrame("Frame")
f:RegisterEvent("BAG_UPDATE")
f:SetScript("OnEvent", OnEvent) ]]
