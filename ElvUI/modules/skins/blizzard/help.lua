local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.help ~= true then return end

	local HelpFrame = _G["HelpFrame"]
	HelpFrame:StripTextures()
	HelpFrame:CreateBackdrop("Transparent")
	HelpFrame.backdrop:Point("TOPLEFT", 6, -2)
	HelpFrame.backdrop:Point("BOTTOMRIGHT", -45, 14)

	local knowFrameButtons = {
		"Cancel",
		"GMTalk",
		"ReportIssue",
		"Stuck",
		"SearchButton",
		"TopIssuesButton"
	}
	for i = 1, #knowFrameButtons do
		local knowButton = _G["KnowledgeBaseFrame"..knowFrameButtons[i]]

		S:HandleButton(knowButton)
	end

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
	for i = 1, #helpFrameButtons do
		local helpButton = _G["HelpFrame"..helpFrameButtons[i]]

		S:HandleButton(helpButton)
	end

	S:HandleCloseButton(HelpFrameCloseButton)
	HelpFrameCloseButton:Point("TOPRIGHT", -42, 0)

	KnowledgeBaseFrame:StripTextures()

	KnowledgeBaseFrameHeader:SetTexture("")
	KnowledgeBaseFrameHeader:ClearAllPoints()
	KnowledgeBaseFrameHeader:Point("TOP", -22, -8)

	HelpFrameOpenTicketDivider:StripTextures()

	HelpFrameOpenTicketScrollFrame:CreateBackdrop()
	HelpFrameOpenTicketScrollFrame.backdrop:Point("TOPLEFT", -4, 2)
	HelpFrameOpenTicketScrollFrame.backdrop:Point("BOTTOMRIGHT", 4, 0)

	S:HandleScrollBar(HelpFrameOpenTicketScrollFrameScrollBar)
	S:HandleScrollBar(KnowledgeBaseArticleScrollFrameScrollBar)

	HelpFrameOpenTicketSubmit:Point("RIGHT", HelpFrameOpenTicketCancel, "LEFT", -2, 0)

	KnowledgeBaseFrameGMTalk:Height(21)

	KnowledgeBaseFrameReportIssue:Point("LEFT", KnowledgeBaseFrameGMTalk, "RIGHT", 2, 0)
	KnowledgeBaseFrameReportIssue:Height(21)

	KnowledgeBaseFrameStuck:Point("LEFT", KnowledgeBaseFrameReportIssue, "RIGHT", 2, 0)
	KnowledgeBaseFrameStuck:Height(21)

	KnowledgeBaseFrameDivider:Kill()
	KnowledgeBaseFrameDivider2:Kill()

	S:HandleEditBox(KnowledgeBaseFrameEditBox)

	KnowledgeBaseFrameEditBox.backdrop:Point("TOPLEFT", -E.Border, -4)
	KnowledgeBaseFrameEditBox.backdrop:Point("BOTTOMRIGHT", E.Border, 6)

	S:HandleDropDownBox(KnowledgeBaseFrameCategoryDropDown)
	KnowledgeBaseFrameCategoryDropDown:Point("TOPLEFT", "KnowledgeBaseFrameEditBox", "TOPRIGHT", -14, -2)

	S:HandleDropDownBox(KnowledgeBaseFrameSubCategoryDropDown)
	KnowledgeBaseFrameSubCategoryDropDown:Point("TOPLEFT", "KnowledgeBaseFrameCategoryDropDown","TOPRIGHT", -24, 0)

	KnowledgeBaseFrameSearchButton:Point("TOPLEFT", "KnowledgeBaseFrameSubCategoryDropDown","TOPRIGHT", -4, -2)

	S:HandleNextPrevButton(KnowledgeBaseArticleListFrameNextButton)
	S:HandleNextPrevButton(KnowledgeBaseArticleListFramePreviousButton)

	S:HandleButton(KnowledgeBaseArticleScrollChildFrameBackButton)
end

S:AddCallback("Help", LoadSkin)