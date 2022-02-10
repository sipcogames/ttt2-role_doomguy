
-- DOOM Eternal muzzleflash effect

EFFECT.Material1 = Material( "effects/doom_eternal/muzzleflash/muzzle_b1.png", "smooth additive" )

EFFECT.Material2 = {}
for i = 1,3 do
	EFFECT.Material2[ i ] = Material( "effects/doom_eternal/muzzleflash/muzzle_d"..i..".png", "smooth additive" )
end

EFFECT.Time = 0

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )

	self.Size = math.Rand( 5, 15 )
	self.Sequence = math.random( 3 )
	
	util.Effect( "dredux_muzzlelight_b", data )
	
end

function EFFECT:Think()

	if !self.Time then self.Time = 0 end
	self.Time = self.Time + FrameTime()
	
	return self.Time < 0.05
	
end

function EFFECT:Render()

	local pos = self:GetTracerShootPos( self.Pos, self.Weapon, self.Att ) + VectorRand() * (self.Sequence-1)
	local size = self.Size + self.Time * 128
	
	render.SetMaterial( self.Material1 )
	render.DrawSprite( pos, size + 5, size + 5, Color( 255, 100, 0, 10 ) )
	
	render.SetMaterial( self.Material2[ self.Sequence ]	)
	render.DrawSprite( pos, size, size, Color( 255, 220, 200, 255 ) )
	render.DrawSprite( pos, size, size, Color( 255, 220, 200, 255 ) )
	
end

