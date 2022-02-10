
-- DOOM Eternal SSG muzzleflash effect

EFFECT.Material = {}
	for i = 1,4 do
		EFFECT.Material[i] = Material( "effects/doom_eternal/muzzleflash/muzzle_c"..i..".png", "smooth" )
	end
EFFECT.Material3 = Material(  "effects/doom_eternal/muzzleflash/muzzle_b1.png", "smooth" )
EFFECT.Material2 = Material(  "effects/fire_cloud2.vmt", "smooth" )
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
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )

	if self.Weapon:GetOwner():GetActiveWeapon():GetClass() == "weapon_dredux_de_supershotgun" then

		local muzEnt = self.IsViewModelEffect && self.Weapon:GetOwner():GetViewModel() || self.Weapon
		local att_dir = muzEnt:GetAttachment( self.Att ).Ang:Forward()

		render.SetMaterial( self.Material[ math.floor( math.Clamp( self.Time * 64, 1, 4 ) ) ] )
		render.DrawBeam( realpos + att_dir * 25, realpos + att_dir, 8, 0, 1, Color( 255, 200, 100 ) )

		if self.IsViewModelEffect then
			local size = 5 + self.Time * 100
			
			render.SetMaterial( self.Material3 )
			render.DrawSprite( realpos + att_dir * 3, size, size, Color( 255, 255, 150, 50 ) )
			
			render.SetMaterial( self.Material2 )
			render.DrawSprite( realpos + att_dir * 3, size, size, Color( 255, 255, 150, 100 ) )
			
		end
		
	end

end