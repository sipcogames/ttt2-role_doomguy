EFFECT.Time = 0

function EFFECT:Init( data )

	local dlight = DynamicLight( self:EntIndex(), false )
	dlight.Pos = data:GetOrigin()
	dlight.Size = 256
	dlight.Decay = 4096
	dlight.R = 255
	dlight.G = 200
	dlight.B = 50
	dlight.Brightness = 1
	dlight.DieTime = CurTime() + 1
	
end

function EFFECT:Think()

	return false

end

function EFFECT:Render()

	return true
	
end