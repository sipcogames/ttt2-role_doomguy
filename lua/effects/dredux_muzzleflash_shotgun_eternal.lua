
-- DOOM Eternal muzzleflash effect

EFFECT.Material1 = Material( "effects/doom_custom/muzzleflash/muzzle_a1.png", "smooth" )
EFFECT.Material2 = Material( "effects/fire_cloud2.vmt", "smooth" )



EFFECT.Time = 0

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	
	if !IsValid( self.Weapon ) then return end
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )
	
	util.Effect( "dredux_muzzlelight_b", data )
	
end

function EFFECT:Think()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end 

	if !self.Time then self.Time = 0 end
	self.Time = self.Time + FrameTime()
	
	return self.Time < 0.075
	
end

function EFFECT:Render()

	local realpos = self:GetTracerShootPos( self.RealPos, self.Weapon, self.Att )
	
	if !IsValid( self.Weapon ) then return end
	
	self:SetPos( realpos )
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )

	local muzEnt = self.IsViewModelEffect && self.Weapon:GetOwner():GetViewModel() || self.Weapon
	local att_dir = muzEnt:GetAttachment( self.Att ).Ang:Forward()

	render.SetMaterial( self.Material1 )
	render.DrawBeam( realpos + att_dir * ( 5 + self.Time * 400 ), realpos , 10, 0, 1, Color( 255, 220, 150 ) )

	if self.IsViewModelEffect then
		local size = 5 + self.Time * 80
		render.SetMaterial( self.Material2 )
		render.DrawSprite( realpos, size, size, Color( 255 * 1, 220 * 1, 150 * 1, 255 ) )
	end

end