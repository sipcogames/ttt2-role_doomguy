
-- DOOM Eternal muzzleflash effect

EFFECT.Material1 = Material( "effects/doom_custom/muzzleflash/muzzle_a1.png", "smooth" )
EFFECT.Material2 = Material( "effects/doom_eternal/muzzleflash/muzzle_b1.png", "smooth" )

EFFECT.Time = 0

function EFFECT:Init( data )

	self.Material3 = Material( "effects/doom_custom/sparks/sparks_b"..math.random(3)..".png", "smooth" )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	self.Magnitude = data:GetMagnitude()	
	
	if !IsValid( self.Weapon ) then return end
	
	self:SetPos( self.Pos )
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )
	
	util.Effect( "dredux_muzzlelight_b", data )
	
end

function EFFECT:Think()

	if !IsValid( self.Weapon ) then return end 

	if !self.Time then self.Time = 0 end
	self.Time = self.Time + FrameTime()
	
	return self.Time < 0.05
	
end

function EFFECT:Render()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end 

	local realpos = self:GetTracerShootPos( self.RealPos, self.Weapon, self.Att )
	
	self:SetPos( realpos )
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )

	if IsValid( self.Weapon ) then

		local muzEnt = self.IsViewModelEffect && self.Weapon:GetOwner():GetViewModel() || self.Weapon
		local att_dir = muzEnt:GetAttachment( self.Att ).Ang:Forward()

		local size = 15+self.Time*1024

		render.SetMaterial( self.Material1 )
		render.DrawBeam( realpos + att_dir*size, realpos, 15, 0, 1, Color( 255, 255, 240 ) )

		if self.IsViewModelEffect then
		
			local size = 10 + self.Time * 160
			render.SetMaterial( self.Material2 )
			render.DrawSprite( realpos, size, size, Color( 255, 255, 220, 150 ) )
			
			if self.Weapon:GetSelectedMod() == 1 && self.Weapon:GetActiveMod() then
			
				local size = 30 + self.Time * 256
				render.SetMaterial( self.Material3 )
				render.DrawSprite( realpos, size, size, Color( 255, 255, 220, 100 ) )
			
			end
			
		end
		
	end

end