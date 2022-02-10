
-- DOOM Pistol muzzleflash effect

EFFECT.Material = Material( "effects/doom_eternal/muzzleflash/muzzle_b2.png", "smooth additive" )
EFFECT.Material2 = Material( "effects/doom/plasma_ball.png", "smooth" )
EFFECT.Material3 = Material( "effects/doom_custom/muzzleflare.png", "smooth additive" )

EFFECT.GlowMaterial =  Material( "particle/particle_glow_04.vmt" )

EFFECT.Time = 0

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	self.Angle = math.random( 360 )
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )
	
	util.Effect( "dredux_muzzlelight_c", data )
	
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
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )

	local normal = -EyeVector()

	local size = ( self.IsViewModelEffect && ( self.Time * 400 ) || ( self.Time * 150 ) )
	render.SetMaterial( self.Material )
	render.DrawQuadEasy( realpos, normal, size, size,Color( 255, 50, 25, 50 ), self.Angle )
	render.DrawQuadEasy( realpos, normal, size, size,Color( 255, 50, 25, 50 ), self.Angle )
	
	
	local size = 16 + self.Time * 1000
	render.SetMaterial( self.Material3 )
	render.DrawQuadEasy( realpos, normal, size, size*0.5, Color( 255, 75, 25 ), 0 )
	render.DrawQuadEasy( realpos, normal, size, size*0.5, Color( 255, 75, 25 ), 0 )
	
	local size = self.Time * 1500
	render.SetMaterial( self.GlowMaterial )
	render.DrawSprite( realpos, size, size, Color( 255, 50, 25, 15 ) )

end