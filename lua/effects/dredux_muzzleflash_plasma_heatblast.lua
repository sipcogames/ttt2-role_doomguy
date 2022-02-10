-- DOOM Pistol muzzleflash effect

EFFECT.Material = Material( "effects/doom_eternal/muzzleflash/muzzle_b2.png", "smooth" )
EFFECT.Material2 = Material( "effects/doom/plasma_ball.png", "smooth" )
EFFECT.Material3 = Material( "effects/doom_custom/flare/flare_1.vmt" )

EFFECT.GlowMaterial =  Material( "particle/particle_glow_04.vmt" )
EFFECT.ShockwaveMaterial = Material( "effects/dredux/explosion_outer_ring_02_a.png", "smooth nocull additive" )
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

	local owner = self.Weapon:GetOwner()
	local normal = -EyeVector()
	local normal2 = owner:EyeAngles():Up()
	local normal3 = owner:GetUp()

	local pos = owner:GetPos() + owner:OBBCenter()

	if self.Time < 0.15 then

		local self_time = self.IsViewModelEffect

		local size = 0 + self.Time * 100
		render.SetMaterial( self.Material )
		render.DrawQuadEasy( realpos, -normal, size, size, Color( 0, 150, 255 ), self.Angle )
		render.DrawQuadEasy( realpos, -normal, size, size, Color( 0, 150, 255 ), self.Angle )
		
		local size = 32 + self.Time * 3000
		render.SetMaterial( self.GlowMaterial )
		render.DrawQuadEasy( pos + normal3, -normal, size, size, Color( 0, 180, 255, 50 ), self.Angle )
		
		--

		local size = 32 + self.Time * 1500
		render.SetMaterial( self.ShockwaveMaterial2 )
		for i = 1, 2 do render.DrawQuadEasy( pos + normal3, normal3, size, size, Color( 0, 180, 255, 100 ), self.Angle ) end
		
		local size = 32 + self.Time * 2500
		render.SetMaterial( self.ShockwaveMaterial )
		for i = 1, 3 do render.DrawQuadEasy( pos + normal3*5, normal3, size, size, Color( 255, 255, 255 ), self.Angle ) end
		
		local size = 32 + self.Time * 1000
		render.SetMaterial( self.ShockwaveMaterial2 )
		for i = 1, 1 do render.DrawQuadEasy( pos + normal3, normal3 - normal*0.25, size, size, Color( 0, 180, 255, 100 ), self.Angle ) end
		
	end
	
end