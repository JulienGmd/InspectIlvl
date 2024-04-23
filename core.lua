-- Ilvl Average text in inspect frame

local inspectFrame = nil
local IlvlFrame = nil
local IlvlText = nil

-- find the inspect frame
function OnEvent(self, event, ...)
  if event == "INSPECT_READY" then
    inspectFrame = _G["InspectFrame"]
    if inspectFrame then
      -- create a frame to hold the AIL text
      IlvlFrame = CreateFrame("Frame", nil, inspectFrame)
      IlvlFrame:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", -4, -34)
      IlvlFrame:SetSize(55, 20)
      -- create a font string to display the AIL
      IlvlText = IlvlFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      IlvlText:SetPoint("CENTER", IlvlFrame, "CENTER")
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
  local Ilvl = C_PaperDollInfo.GetInspectItemLevel(unit)
  IlvlText:SetText(string.format("%.1f", Ilvl))
end

local f = CreateFrame("Frame")
f:RegisterEvent("INSPECT_READY")
f:SetScript("OnEvent", OnEvent)
