EFFECT.Material = {}
	for i = 1,4 do
		EFFECT.Material[i] = Material( "effects/doom_eternal/muzzleflash/muzzle_c"..i..".png", "smooth" )
	end
	
EFFECT.Material2 = Material( "effects/doom_eternal/muzzleflash/muzzle_b1.png", "smooth" )
EFFECT.GlowMaterial =  Material( "particle/particle_glow_04.vmt" )

EFFECT.Time = 0
EFFECT.Size = 0

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	
	self.RealPos = self:GetTracerShootPos(self.Pos, self.Weapon, self.Att)
	self.Time = 0
	self.Size = math.Rand( 2, 5 )
	
	util.Effect( "dredux_muzzlelight_b", data )
	
	--[[local owner = self.Weapon:GetOwner()
	
	local muzEnt = ((owner != LocalPlayer()) or owner:ShouldDrawLocalPlayer()) && ent or owner:GetViewModel() -- From vj base, lol
	ParticleEffectAttach( "d_muzzleflash", PATTACH_POINT, muzEnt, 1 )]]

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

	if IsValid( muzEnt ) && ( self.Weapon:GetOwner():GetActiveWeapon():GetClass() == "weapon_dredux_d2016_heavy_ar" ) then
	
		local att_right = muzEnt:GetAttachment( self.Att ).Ang:Right()
		local att_up = muzEnt:GetAttachment( self.Att ).Ang:Up()

		self:SetPos( realpos )

		render.SetMaterial( self.Material[ math.floor( math.Clamp( self.Time * 40, 1, 3 ) ) ] )
		local size = ( 5 + self.Time * 300 )
		
		render.DrawBeam( realpos + att_right * size, realpos , 5, 0, 1, Color( 255 * 1, 240 * 1, 200 * 1 ) )
		render.DrawBeam( realpos + att_right * -size, realpos , 5, 0, 1, Color( 255 * 1, 240 * 1, 200 * 1 ) )
		render.DrawBeam( realpos + att_up * size, realpos , 5, 0, 1, Color( 255 * 1, 240 * 1, 200 * 1 ) )
		render.DrawBeam( realpos + att_up * -size, realpos , 5, 0, 1, Color( 255 * 1, 240 * 1, 200 * 1 ) )
		
		if self.IsViewModelEffect then
			local size = self.Time * 128
			render.SetMaterial( self.Material2 )
			render.DrawSprite( realpos, size, size, Color( 255 * 1, 255 * 1, 255 * 1, 255 ) )
			
			local size = self.Time * 1024
			render.SetMaterial( self.GlowMaterial )
			render.DrawSprite( realpos, size, size, Color( 255, 200, 0, 15 ) )
		end
	
	end

end