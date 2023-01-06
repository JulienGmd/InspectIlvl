-- ILvl Average text in inspect frame

local inspectFrame = nil
local AILFrame = nil
local AILText = nil

-- find the inspect frame
function OnEvent(self, event, ...)
  if event == "INSPECT_READY" then
    inspectFrame = _G["InspectFrame"]
    if inspectFrame then
      -- create a frame to hold the AIL text
      AILFrame = CreateFrame("Frame", nil, inspectFrame)
      AILFrame:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", -4, -34)
      AILFrame:SetSize(55, 20)
      -- create a font string to display the AIL
      AILText = AILFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      AILText:SetPoint("CENTER", AILFrame, "CENTER")

      -- Unregister the event (which is called multiple times the same frame...), we don't need it anymore
      self:UnregisterEvent("INSPECT_READY")
      -- hook the OnShow event of the inspect frame
      hooksecurefunc(inspectFrame, "Show", OnInspectFrameShow)
    end
  end
end

-- update the AIL text when the inspect frame is shown
function OnInspectFrameShow()
  local unit = inspectFrame.unit
  local AIL = C_PaperDollInfo.GetInspectItemLevel(unit)
  AILText:SetText(string.format("%.1f", AIL))
end

local f = CreateFrame("Frame")
f:RegisterEvent("INSPECT_READY")
f:SetScript("OnEvent", OnEvent)

-- utiliser local itemLink = GetInventoryItemLink(unit, GetInventorySlotInfo(("%sSlot"):format(Slots[i])));
-- unit est censé etre contenu dans InspectionFrame.unit
