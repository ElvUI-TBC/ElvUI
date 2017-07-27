local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G

function S:LoadHelpSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.help ~= true) then return end

	local knowFrameButtons = {
		"Cancel",
		"GMTalk",
		"ReportIssue",
		"Stuck",
		"SearchButton",
		"TopIssuesButton"
	}

	local helpFrameButtons = {
		"GMTalkOpenTicket",
		"GMTalkCancel",
		"OpenTicketSubmit",
		"OpenTicketCancel",
		"ReportIssueOpenTicket",
		"ReportIssueCancel",
		"StuckStuck",
		"StuckOpenTicket",
		"StuckCancel"
	}

	HelpFrame:StripTextures()
	HelpFrame:CreateBackdrop("Transparent")
	HelpFrame.backdrop:Point("TOPLEFT", 6, -2)
	HelpFrame.backdrop:Point("BOTTOMRIGHT", -45, 14)

	S:HandleCloseButton(HelpFrameCloseButton)
	HelpFrameCloseButton:Point("TOPRIGHT", -42, 0)

	for i = 1, #knowFrameButtons do
		local knowButton = _G["KnowledgeBaseFrame" .. knowFrameButtons[i]]
		S:HandleButton(knowButton)
	end

	for i = 1, #helpFrameButtons do
		local helpButton = _G["HelpFrame" .. helpFrameButtons[i]]
		S:HandleButton(helpButton)
	end

	-- hide header textures and move text/buttons.
	local BlizzardHeader = {
		"KnowledgeBaseFrame"
	}

	for i = 1, #BlizzardHeader do
		local title = _G[BlizzardHeader[i].."Header"]
		if title then
			title:SetTexture("")
			title:ClearAllPoints()
			if title == _G["GameMenuFrameHeader"] then
				title:Point("TOP", GameMenuFrame, 0, 0)
			else
				title:Point("TOP", BlizzardHeader[i], -22, -8)
			end
		end
	end

	HelpFrameOpenTicketDivider:StripTextures()

	S:HandleScrollBar(HelpFrameOpenTicketScrollFrame)
	S:HandleScrollBar(HelpFrameOpenTicketScrollFrameScrollBar)
	S:HandleScrollBar(KnowledgeBaseArticleScrollFrameScrollBar)

	HelpFrameOpenTicketSubmit:Point("RIGHT", HelpFrameOpenTicketCancel, "LEFT", -2, 0)
	KnowledgeBaseFrameStuck:Point("LEFT", KnowledgeBaseFrameReportIssue, "RIGHT", 2, 0)

	KnowledgeBaseFrame:StripTextures()

	KnowledgeBaseFrameDivider:Kill()
	KnowledgeBaseFrameDivider2:Kill()

	S:HandleEditBox(KnowledgeBaseFrameEditBox)

	KnowledgeBaseFrameEditBox.backdrop:Point("TOPLEFT", -E.Border, -4)
	KnowledgeBaseFrameEditBox.backdrop:Point("BOTTOMRIGHT", E.Border, 7)

	S:HandleDropDownBox(KnowledgeBaseFrameCategoryDropDown)
	KnowledgeBaseFrameCategoryDropDown:Point("TOPLEFT", "KnowledgeBaseFrameEditBox", "TOPRIGHT", -14, -3)

	S:HandleDropDownBox(KnowledgeBaseFrameSubCategoryDropDown)
	KnowledgeBaseFrameSubCategoryDropDown:Point("TOPLEFT", "KnowledgeBaseFrameCategoryDropDown","TOPRIGHT", -24, 0)

	KnowledgeBaseFrameSearchButton:Point("TOPLEFT", "KnowledgeBaseFrameSubCategoryDropDown","TOPRIGHT", -4, -2)

	S:HandleNextPrevButton(KnowledgeBaseArticleListFrameNextButton)
	S:HandleNextPrevButton(KnowledgeBaseArticleListFramePreviousButton)

	S:HandleButton(KnowledgeBaseArticleScrollChildFrameBackButton)
end

S:AddCallback("Help", S.LoadHelpSkin)