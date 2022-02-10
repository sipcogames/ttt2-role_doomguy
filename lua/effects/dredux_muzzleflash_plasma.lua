
-- DOOM Pistol muzzleflash effect

EFFECT.Material = Material( "effects/doom_eternal/muzzleflash/muzzle_b2.png", "smooth" )
EFFECT.Material2 = Material( "effects/doom/plasma_ball.png", "smooth" )
EFFECT.Material3 = Material( "effects/doom_custom/muzzleflare.png", "smooth additive" )

EFFECT.Time = 0

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	self.Angle = math.random( 360 )
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )
	
	util.Effect( "dredux_muzzlelight_a", data )
	
end

function EFFECT:Think()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end 

	if !self.Time then self.Time = 0 end
	self.Time = self.Time + FrameTime()
	
	return self.Time < 0.075
	
end

function EFFECT:Render()

	local realpos = self:GetTracerShootPos( self.RealPos, self.Weapon, self.Att )
	self:SetPos( realpos )
	
	if !IsValid( self.Weapon ) then return end
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )

	local normal = -EyeVector()

	local size = 0 + self.Time * 200
	render.SetMaterial( self.Material )
	render.DrawQuadEasy( realpos, normal, size, size,Color( 0, 125, 255, 255 ), self.Angle )
	render.DrawQuadEasy( realpos, normal, size, size,Color( 0, 125, 255, 255 ), self.Angle )
	
	--local size = 0 + self.Time * 200
	--render.SetMaterial( self.Material2 )
	--render.DrawQuadEasy( realpos, normal, size, size,Color( 0, 200, 255, 100 ), self.Angle )
	
	local size = 0 + self.Time * 400
	render.SetMaterial( self.Material3 )
	render.DrawQuadEasy( realpos, normal, size, size*0.5, Color( 0, 150, 255, 255 ), 0 )

end