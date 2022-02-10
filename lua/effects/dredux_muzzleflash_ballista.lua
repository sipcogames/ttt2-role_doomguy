
-- DOOM Pistol muzzleflash effect

EFFECT.Material = Material(  "effects/fire_cloud2.vmt", "smooth" )
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
	
	if !IsValid( self.Weapon ) then return end
	
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
	
	local size = 16 + self.Time * 1000
	render.SetMaterial( self.Material3 )
	render.DrawQuadEasy( realpos, normal, size, size*0.5, Color( 255, 150, 0 ), 0 )
	
	local size = self.Time * 250
	render.SetMaterial( self.Material )
	render.DrawQuadEasy( realpos, normal, size, size,Color( 255, 255, 200, 200 ), self.Angle )
	
	local size = self.Time * 1000
	render.SetMaterial( self.GlowMaterial )
	render.DrawSprite( realpos, size, size, Color( 255, 150, 0, 10 ) )

end