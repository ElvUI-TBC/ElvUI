local E, L, V, P, G = unpack(ElvUI);
local S = E:GetModule("Skins");

function S:LoadErrorSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.debug ~= true then return end
	if IsAddOnLoaded("!DebugTools") then return end

	ScriptErrors:SetParent(UIParent)
	ScriptErrors:SetTemplate("Transparent")
	S:HandleButton(ScriptErrorsButton)

	ScriptErrors_Message:SetFont("Fonts\\FRIZQT__.TTF", 15, "NORMAL")
end

function S:LoadDebugSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.debug ~= true then return end

	ScriptErrorsFrame:SetParent(E.UIParent)
	ScriptErrorsFrame:SetTemplate("Transparent")
	S:HandleScrollBar(ScriptErrorsFrameScrollFrameScrollBar)
	S:HandleCloseButton(ScriptErrorsFrameClose)
	ScriptErrorsFrameScrollFrameText:FontTemplate(nil, 13)
	ScriptErrorsFrameScrollFrame:CreateBackdrop("Default")
	ScriptErrorsFrameScrollFrame:SetFrameLevel(ScriptErrorsFrameScrollFrame:GetFrameLevel() + 2)

	EventTraceFrame:SetTemplate("Transparent")
	S:HandleSliderFrame(EventTraceFrameScroll)

	local texs = {
		"TopLeft",
		"TopRight",
		"Top",
		"BottomLeft",
		"BottomRight",
		"Bottom",
		"Left",
		"Right",
		"TitleBG",
		"DialogBG",
	}

	for i = 1, #texs do
		_G["ScriptErrorsFrame"..texs[i]]:SetTexture(nil)
		_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
	end

	S:HandleButton(ScriptErrorsFrame.reload)
	S:HandleNextPrevButton(ScriptErrorsFrame.previous)
	S:HandleNextPrevButton(ScriptErrorsFrame.next)
	S:HandleButton(ScriptErrorsFrame.close)

	local function SkinFirstLast()
		S:HandleButton(ScriptErrorsFrame.firstButton)
		S:HandleButton(ScriptErrorsFrame.lastButton)
	end

	local DT = E:GetModule("DebugTools")
	if DT.HideFrame then
		SkinFirstLast()
	else
		hooksecurefunc(DT, "ModifyErrorFrame", SkinFirstLast)
	end

	-- TODO FIX HandleNextPrevButton button size
	ScriptErrorsFrame.previous:Point("BOTTOM", ScriptErrorsFrame, "BOTTOM", -50, 12)
	ScriptErrorsFrame.next:Point("BOTTOM", ScriptErrorsFrame, "BOTTOM", 50, 12)

	local noscalemult = E.mult * GetCVar("uiScale")
	FrameStackTooltip:HookScript("OnShow", function(self)
		self:SetBackdrop({
			bgFile = E["media"].blankTex,
			edgeFile = E["media"].blankTex,
			tile = false, tileSize = 0, edgeSize = noscalemult,
			insets = { left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
		});
		self:SetBackdropColor(unpack(E["media"].backdropfadecolor))
		self:SetBackdropBorderColor(unpack(E["media"].bordercolor))
	end)

	EventTraceTooltip:HookScript("OnShow", function(self)
		self:SetTemplate("Transparent")
	end)

	S:HandleCloseButton(EventTraceFrameCloseButton)
end

S:AddCallback("SkinErrorFrame", S.LoadErrorSkin)
S:AddCallbackForAddon("!DebugTools", "SkinDebugTools", S.LoadDebugSkin)