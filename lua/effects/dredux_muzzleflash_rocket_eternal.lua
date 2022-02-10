
-- DOOM Eternal muzzleflash effect

EFFECT.Material1 = Material(  "effects/fire_cloud2.vmt", "smooth" )
EFFECT.Material2 = Material( "effects/doom_eternal/muzzleflash/muzzle_b1.png", "smooth" )



EFFECT.Time = 0

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	
	if !IsValid( self.Weapon ) then return end
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )
	
	self.Angle = math.random( 0, 360 )
	
	self.IsDEWeapon = ( self.Weapon:GetClass() == "weapon_dredux_de_rocketlauncher" )
	util.Effect( "dredux_muzzlelight_c", data )
	
end

function EFFECT:Think()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end 

	if !self.Time then self.Time = 0 end
	self.Time = self.Time + FrameTime()
	
	return self.Time < 0.1
	
end

function EFFECT:Render()

	local realpos = self:GetTracerShootPos( self.RealPos, self.Weapon, self.Att )
	
	if !IsValid( self.Weapon ) then return end
	
	self:SetPos( realpos )
	
	local normal = -EyeVector()

	local color = self.IsDEWeapon && Color( 255, 200, 200, 255 ) || Color( 255, 240, 200, 255 )

	local size = 5 + self.Time * 160
	render.SetMaterial( self.Material2 )
	render.DrawQuadEasy( realpos, normal, size, size, color, self.Angle )

	local size = 5 + self.Time * 160
	render.SetMaterial( self.Material1 )
	render.DrawQuadEasy( realpos, normal, size, size, color, self.Angle )

end