local E, L, V, P, G = unpack(ElvUI);
local UF = E:GetModule("UnitFrames");

function UF:Construct_RaidIcon(frame)
	local tex = frame.RaisedElementParent:CreateTexture(nil, "OVERLAY");
	tex:SetTexture([[Interface\AddOns\ElvUI\media\textures\raidicons]]);
	tex:Size(18);
	tex:Point("CENTER", frame.Health, "TOP", 0, 2);
	tex.SetTexture = E.noop;

	return tex;
end

function UF:Configure_RaidIcon(frame)
	local RI = frame.RaidTargetIndicator;
	local db = frame.db;

	if(db.raidicon.enable) then
		frame:EnableElement("RaidTargetIndicator");
		RI:Show();
		RI:Size(db.raidicon.size);

		local attachPoint = self:GetObjectAnchorPoint(frame, db.raidicon.attachToObject);
		RI:ClearAllPoints();
		RI:Point(db.raidicon.attachTo, attachPoint, db.raidicon.attachTo, db.raidicon.xOffset, db.raidicon.yOffset);
	else
		frame:DisableElement("RaidTargetIndicator");
		RI:Hide();
	end
end