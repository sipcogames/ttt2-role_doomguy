EFFECT.BeamMaterial = Material( "trails/electric" )
EFFECT.TextureEnd = 0


function EFFECT:Init( data )

	self.Entity = data:GetEntity()
	self.EndPos = data:GetOrigin()
	
	self:SetPos( self.EndPos )
	

	self.RealPos = self:GetTracerShootPos(self.Pos, self.Weapon, self.Att )
	
	self.Time = 0
	
	if IsValid( self.Entity ) then
	
		self.TextureEnd = ( self.Entity:GetPos() - self.EndPos ):Length() * 0.01
	
	end

end

function EFFECT:Think()

	self.Time = self.Time + FrameTime()
	return IsValid( self.Entity ) && self.Time < 0.2

end

function EFFECT:Render()

	if !IsValid( self.Entity ) then return end

	render.SetMaterial( self.BeamMaterial )
	render.DrawBeam( self.Entity:GetPos(), self.EndPos, 30, 0, self.TextureEnd, Color( 0, 255, 0, self.Alpha ) )
	
	return true

end