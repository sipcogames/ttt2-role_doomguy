EFFECT.Material = {}
EFFECT.Material1 = Material( "effects/dredux/bfg/bfg_a1.png", "smooth" )
EFFECT.Material2 = Material( "effects/muzzleflash2.vmt" )
EFFECT.Material3 = Material( "effects/muzzleflash3.vmt" )

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	
	self.RealPos = self:GetTracerShootPos(self.Pos, self.Weapon, self.Att )
	
	local MuzEnt = ( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() ) && self.Weapon || self.Weapon:GetOwner():GetViewModel()
	ParticleEffectAttach( "d_bfg_muzzle", PATTACH_POINT_FOLLOW, MuzEnt, MuzEnt:LookupAttachment( "muzzle" ) )
	
end

function EFFECT:Think()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end 
	
	if !self.Time then self.Time = 0 end
	self.Time = self.Time + FrameTime()
	return self.Time < 0.5
	
end

function EFFECT:Render()

	return true

end