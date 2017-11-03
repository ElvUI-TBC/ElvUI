local E, L, V, P, G = unpack(ElvUI);
local UF = E:GetModule("UnitFrames");

function UF:Construct_RestingIndicator(frame)
	local parent = frame.RaisedElementParent or frame;
	local resting = parent:CreateTexture(nil, "OVERLAY");
	resting:Size(22);

	return resting;
end

function UF:Configure_RestingIndicator(frame)
	if(not frame.VARIABLES_SET) then return; end
	local rIcon = frame.RestingIndicator;
	local db = frame.db
	if(db.restIcon) then
		if(not frame:IsElementEnabled("RestingIndicator")) then
			frame:EnableElement("RestingIndicator");
		end

		rIcon:ClearAllPoints();
		if(frame.ORIENTATION == "RIGHT") then
			rIcon:Point("CENTER", frame.Health, "TOPLEFT", -3, 6);
		else
			if(frame.USE_PORTRAIT and not frame.USE_PORTRAIT_OVERLAY) then
				rIcon:Point("CENTER", frame.Portrait, "TOPLEFT", -3, 6);
			else
				rIcon:Point("CENTER", frame.Health, "TOPLEFT", -3, 6);
			end
		end
	elseif(frame:IsElementEnabled("RestingIndicator")) then
		frame:DisableElement("RestingIndicator");
		rIcon:Hide();
	end
end