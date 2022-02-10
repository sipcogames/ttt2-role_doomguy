-- DOOM Pistol muzzleflash effect

EFFECT.BoltMaterial = {}
for i = 0, 8 do
	EFFECT.BoltMaterial[ i ] = Material( "effects/dredux/bolt/bolt_a"..i..".png", "smooth nocull" )
end

EFFECT.GlowMaterial =  Material( "particle/particle_glow_04.vmt" )
EFFECT.ShockwaveMaterial = Material( "effects/dredux/explosion_outer_ring_02_b.png", "smooth additive nocull" )
EFFECT.ShockwaveMaterial2 = Material( "effects/doom_eternal/shockwave_lightning.png", "smooth additive nocull" )

EFFECT.ShockwaveMaterial2 = Material( "effects/doom_eternal/shockwave_lightning.png", "smooth nocull" )

EFFECT.Time = 0

function EFFECT:Init( data )

	self.Weapon = data:GetEntity()
	
	local owner = self.Weapon:GetOwner()
	self.Pos = owner:GetPos() + owner:OBBCenter() + owner:GetUp()*15 + owner:GetForward()*20
	
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
	
	if !IsValid( self.Weapon ) || !self.Weapon:GetActiveMod() then return end
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )

	local owner = self.Weapon:GetOwner()
	local normal = -EyeVector()
	local normal3 = owner:GetUp()

	local pos = owner:GetPos() + owner:OBBCenter() + owner:GetUp()*-15 + owner:GetForward()*10
	
	self:SetPos( pos )

	if self.Time < 0.2 then

		local size = 32 + self.Time * 2000
		render.SetMaterial( self.GlowMaterial )
		render.DrawQuadEasy( pos + normal3, -normal, size, size, Color( 0, 180, 255, 50 ), self.Angle )

		local size = 32 + self.Time * 1500
		render.SetMaterial( self.ShockwaveMaterial )
		for i = 1, 2 do render.DrawQuadEasy( pos + normal3, normal3, size, size, Color( 255, 255, 255, 255 ), self.Angle ) end
		
	end
	
end