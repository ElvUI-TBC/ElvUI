local E, L, V, P, G = unpack(ElvUI);
local UF = E:GetModule("UnitFrames");

local CreateFrame = CreateFrame;

function UF:Construct_HealComm(frame)
	local mhpb = CreateFrame("StatusBar", nil, frame.Health);
	mhpb:SetStatusBarTexture(E["media"].blankTex);
	mhpb:Hide();

	local ohpb = CreateFrame("StatusBar", nil, frame.Health);
	ohpb:SetStatusBarTexture(E["media"].blankTex);
	ohpb:Hide();

	CreateStatusBarTexturePointer(mhpb)

	return {
		myBar = mhpb,
		otherBar = ohpb,
		maxOverflow = 1,
		PostUpdate = UF.UpdateHealComm,
	};
end

function UF:Configure_HealComm(frame)
	local healCommBar = frame.HealCommBar;
	local c = self.db.colors.healPrediction;

	if(frame.db.healPrediction) then
		if(not frame:IsElementEnabled("HealComm3")) then
			frame:EnableElement("HealComm3");
		end

		if(not frame.USE_PORTRAIT_OVERLAY) then
			healCommBar.myBar:SetParent(frame.Health);
			healCommBar.otherBar:SetParent(frame.Health);
		else
			healCommBar.myBar:SetParent(frame.Portrait.overlay);
			healCommBar.otherBar:SetParent(frame.Portrait.overlay);
		end

		local orientation = frame.db.health and frame.db.health.orientation;
		if(orientation) then
			healCommBar.myBar:SetOrientation(orientation);
			healCommBar.otherBar:SetOrientation(orientation);
		end

		healCommBar.myBar:SetStatusBarColor(c.personal.r, c.personal.g, c.personal.b, c.personal.a);
		healCommBar.otherBar:SetStatusBarColor(c.others.r, c.others.g, c.others.b, c.others.a);
	else
		if(frame:IsElementEnabled("HealComm3")) then
			frame:DisableElement("HealComm3");
		end
	end
end

local function UpdateFillBar(frame, previousTexture, bar, amount)
	if(amount == 0) then
		bar:Hide();
		return previousTexture;
	end

	local orientation = frame.Health:GetOrientation();
	bar:ClearAllPoints();
	if(orientation == "HORIZONTAL") then
		bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT");
		bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT");
	else
		bar:SetPoint("BOTTOMRIGHT", previousTexture, "TOPRIGHT");
		bar:SetPoint("BOTTOMLEFT", previousTexture, "TOPLEFT");
	end

	local totalWidth, totalHeight = frame.Health:GetSize();
	if(orientation == "HORIZONTAL") then
		bar:SetWidth(totalWidth);
	else
		bar:SetHeight(totalHeight);
	end

	return bar.texturePointer
end

function UF:UpdateHealComm(_, myIncomingHeal, allIncomingHeal)
	local frame = self.parent;
	local previousTexture = frame.Health.texturePointer

	previousTexture = UpdateFillBar(frame, previousTexture, self.myBar, myIncomingHeal);
	previousTexture = UpdateFillBar(frame, previousTexture, self.otherBar, allIncomingHeal);
end