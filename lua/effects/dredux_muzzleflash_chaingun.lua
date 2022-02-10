
-- DOOM Eternal muzzleflash effect

EFFECT.Material1 = Material( "effects/doom_eternal/muzzleflash/muzzle_d1.png", "smooth additive" )
EFFECT.Material2 = Material( "effects/doom_eternal/muzzleflash/muzzle_e1.png", "smooth additive" )

EFFECT.GlowMaterial =  Material( "particle/particle_glow_04.vmt" )

EFFECT.Time = 0

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	if !IsValid( self.Weapon ) then return end
	
	self.Size = self.Weapon:GetActiveMod() && math.Rand( 6, 12 ) || math.Rand( 20, 25 )
	self.Sequence = math.random( 3 )
	
	self.UraniumCoating = ( self.Weapon:GetSelectedMod() == 1 ) || self.Weapon:GetClass() == "weapon_dredux_de_chaingun"
	self.Angle = math.random( 0, 360 )
	
	local effect = self.UraniumCoating && "dredux_muzzlelight_a" || "dredux_muzzlelight_b"
	util.Effect( effect, data )
	
end

function EFFECT:Think()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end 
	
	if !self.Time then self.Time = 0 end
	self.Time = self.Time + FrameTime()
	
	return self.Time < 0.06
	
end

function EFFECT:Render()
	
	if IsValid( self.Weapon ) && ( self.Weapon:GetClass() == "weapon_dredux_d2016_chaingun" || self.Weapon:GetClass() == "weapon_dredux_de_chaingun" ) then
		
		local realpos = self:GetTracerShootPos( self.RealPos, self.Weapon, self.Att )
		if !realpos then return end
		
		self:SetPos( realpos )
		local normal = -EyeVector()
		
		
		
		if !self.UraniumCoating then
			
			local size = self.Size + self.Time * 100
			render.SetMaterial( self.Material1 )
			render.DrawQuadEasy( realpos, normal, size, size, Color( 255, 240, 200, 255 ), self.Angle )
			
			local size = self.Size + self.Time * 300
			render.SetMaterial( self.GlowMaterial )
			render.DrawQuadEasy( realpos, normal, size, size, Color( 255, 200, 0, 75 ), 0 )
			
		else
		
			local size = self.Size + self.Time * 100
			render.SetMaterial( self.Material2 )
			render.DrawQuadEasy( realpos, normal, size, size, Color( 240, 240, 255, 255 ), self.Angle )
			
			local size = self.Size + self.Time * 300
			render.SetMaterial( self.GlowMaterial )
			render.DrawQuadEasy( realpos, normal, size, size,  Color( 0, 150, 255, 125 ), 0 )
			
		
		end
		
	end

end