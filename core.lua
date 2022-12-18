-- After a bag is oppened or an item was moved in a bag
EventRegistry:RegisterCallback("ItemButton.UpdateItemContextMatching", function(event, bagId)

  -- Loop through the slots of the bag, if the slot can be equipped, and has a greater ilvl than
  -- the currently equipped item in the same slot, mark it with an arrow


  -- Loop through the slots of the bag
  local numSlots = C_Container.GetContainerNumSlots(bagId)
  for slotId = 1, numSlots do

    -- Get the item frame
    local bagFrameId = GetBagFrameId(bagId)
    local itemFrameId = numSlots - slotId + 1 -- Because the item frames are in reverse order
    local itemFrame = _G["ContainerFrame" .. bagFrameId .. "Item" .. itemFrameId]

    local itemLink = C_Container.GetContainerItemLink(bagId, slotId)
    if itemLink then
      local invSlotId = GetInvSlotId(itemLink)
      -- If item can be equipped in
      -- head(1), neck(2), shoulder(3), shirt(4), chest(5), waist(6), legs(7), feet(8),
      -- wrist(9), hands(10), finger(11), finger(12), trinket(13), trinket(14), back(15),
      -- main hand(16), off hand(17), ranged(18)
      if invSlotId and invSlotId >= 1 and invSlotId <= 18 then

        -- Compare ilvls
        local _, _, _, itemLevel = GetItemInfo(itemLink)
        local equippedItemLevel = GetEquippedItemLevel(invSlotId)

        -- If ring, trinket or 1H weapon, compare with both slots
        if invSlotId == 11 or invSlotId == 13 or invSlotId == 16 then
          local equippedItemLevel2 = GetEquippedItemLevel(invSlotId + 1)
          if equippedItemLevel2 < equippedItemLevel then
            equippedItemLevel = equippedItemLevel2
          end
        end

        if itemLevel > equippedItemLevel then
          -- Show or create the arrow texture
          if itemFrame["ILvlUpgradeTex"] then
            itemFrame["ILvlUpgradeTex"]:Show()
          else
            itemFrame["ILvlUpgradeTex"] = itemFrame:CreateTexture(nil, "OVERLAY")
            itemFrame["ILvlUpgradeTex"]:SetTexture("Interface\\MINIMAP\\MiniMap-QuestArrow")
            itemFrame["ILvlUpgradeTex"]:SetPoint("TOPRIGHT", itemFrame, "TOPRIGHT", 6, 4)
            itemFrame["ILvlUpgradeTex"]:SetSize(26, 26)
          end

        else
          HideArrowFrame(itemFrame)
        end
      else
        HideArrowFrame(itemFrame)
      end
    else
      HideArrowFrame(itemFrame)
    end
  end
end)




-- Returns:
-- The bag frame corresponding to the bagId
-- The bag frame id (1 to 6)
function GetBagFrameId(bagId)
  for bagFrameId = 1, 6 do
    local bagFrame = _G["ContainerFrame" .. bagFrameId]

    -- Check if this bag frame id is equal to input param bagId
    -- Because when opening a bag, the same bag can be ContainerFrame1 or 2 or 3 or 4 or 5 or 6
    -- depending on the order you open the bags (it's not related to the bagId)
    if bagFrame:IsShown() and bagFrame:GetBagID() == bagId then
      return bagFrameId
    end
  end
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
  INVTYPE_SHIELD = 17,
  INVTYPE_RANGED = 18,
  INVTYPE_2HWEAPON = 16,
  INVTYPE_WEAPONMAINHAND = 16,
  INVTYPE_WEAPONOFFHAND = 17,
  INVTYPE_HOLDABLE = 17,
  INVTYPE_RANGEDRIGHT = 18,
  INVTYPE_THROWN = 18,
  INVTYPE_RELIC = 18,
}

function GetInvSlotId(itemLink)
  local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
  if invSlotIds[itemEquipLoc] then
    return invSlotIds[itemEquipLoc]
  end
end

-- Returns the item level of the equipped item in invSlotId
function GetEquippedItemLevel(invSlotId)
  local itemLink = GetInventoryItemLink("player", invSlotId)
  if itemLink then
    local _, _, _, itemLevel = GetItemInfo(itemLink)
    return itemLevel
  end
  return 0
end

function HideArrowFrame(itemFrame)
  if itemFrame["ILvlUpgradeTex"] then
    itemFrame["ILvlUpgradeTex"]:Hide()
  end
end
