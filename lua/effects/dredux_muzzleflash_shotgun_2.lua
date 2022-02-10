
-- DOOM Eternal muzzleflash effect

EFFECT.Material1 = Material( "effects/doom_custom/muzzleflash/muzzle_a1.png", "smooth" )
EFFECT.Material2 = Material( "effects/doom_eternal/muzzleflash/muzzle_b1.png", "smooth" )



EFFECT.Time = 0

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )
	
	util.Effect( "dredux_muzzlelight_b", data )

end

function EFFECT:Think()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end 
	
	if !self.Time then self.Time = 0 end
	self.Time = self.Time + FrameTime()
	
	return self.Time < 0.05
	
end

function EFFECT:Render()

	local realpos = self:GetTracerShootPos( self.RealPos, self.Weapon, self.Att )
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )

	local muzEnt = self.IsViewModelEffect && self.Weapon:GetOwner():GetViewModel() || self.Weapon
	local att_dir = muzEnt:GetAttachment( self.Att ).Ang:Forward()

	render.SetMaterial( self.Material1 )
	render.DrawBeam( realpos + att_dir * 60, realpos + att_dir * 5 , 12, 0, 1, Color( 255, 240, 220 ) )

	if self.IsViewModelEffect then
	
		local size = 10 + self.Time * 100
		render.SetMaterial( self.Material2 )
		render.DrawSprite( realpos, size, size, Color( 255, 255, 200, 150 ) )
		
	end

end