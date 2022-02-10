-- DOOM Pistol muzzleflash effect

EFFECT.Material = Material( "effects/doom_eternal/muzzleflash/muzzle_b2.png", "smooth" )
EFFECT.Material2 = Material( "effects/doom/plasma_ball.png", "smooth" )
EFFECT.Material3 = Material( "effects/doom_custom/flare/flare_1.vmt" )

EFFECT.GlowMaterial =  Material( "particle/particle_glow_04.vmt" )
EFFECT.ShockwaveMaterial = Material( "effects/dredux/explosion_outer_ring_02_b.png", "smooth nocull additive" )
EFFECT.ShockwaveMaterial2 = Material( "effects/doom_eternal/shockwave_lightning.png", "smooth nocull" )

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
	
	return self.Time < 1
	
end

function EFFECT:Render()

	local realpos = self:GetTracerShootPos( self.RealPos, self.Weapon, self.Att )
	
	if !IsValid( self.Weapon ) then return end
	
	self:SetPos( realpos )
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )

	local normal = self.Weapon:GetOwner():GetAimVector()

	if self.Time < 0.15 then

		local size = 32 + self.Time * 200
		render.SetMaterial( self.Material )
		render.DrawQuadEasy( realpos, -normal, size, size, Color( 255, 100, 0 ), self.Angle )
		render.DrawQuadEasy( realpos, -normal, size, size, Color( 255, 100, 0 ), self.Angle )
		
		local size = 32 + self.Time * 1800
		render.SetMaterial( self.GlowMaterial )
		render.DrawQuadEasy( realpos, -normal, size, size, Color( 255, 100, 0, 25 ), self.Angle )
		render.DrawQuadEasy( realpos, -normal, size, size, Color( 255, 100, 0, 25 ), self.Angle )
		
		--

		--[[local size = 32 + self.Time * 400
		render.SetMaterial( self.ShockwaveMaterial2 )
		for i = 1, 2 do render.DrawQuadEasy( realpos + normal, normal, size, size, Color( 255, 100, 0 ), self.Angle ) end]]
		
		local size = 32 + self.Time * 1000
		render.SetMaterial( self.ShockwaveMaterial )
		for i = 1, 2 do render.DrawQuadEasy( realpos + normal * size * 0.2, normal, size, size, Color( 255, 255, 255 ), self.Angle ) end
		
		local size = 32 + self.Time * 1800
		render.SetMaterial( self.ShockwaveMaterial )
		for i = 1, 2 do render.DrawQuadEasy( realpos + normal * size * 0.2, normal, size, size, Color( 255, 255, 255 ), self.Angle ) end
		
	end
	
end