EFFECT.Material = Material( "effects/dredux/bfg/bfg_a1.png", "smooth" )
EFFECT.Material2 = Material( "effects/dredux/ground_ripple2.png", "smooth" )

EFFECT.Time = 0
EFFECT.Size = 0


function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	self.RealPos = self:GetTracerShootPos(self.Pos, self.Weapon, self.Att )
	
	self.Size = math.random( 10, 30 )
	
	debugoverlay.Cross( self.RealPos, 25, 1 )
	
end

function EFFECT:Think()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end 
	
	if !self.Time then self.Time = 0 end
	self.Time = self.Time + FrameTime()
	return self.Time < 0.15
	
end

function EFFECT:Render()

	local realpos = self:GetTracerShootPos( self.RealPos, self.Weapon, self.Att )
	
	render.SetMaterial( self.Material )
	local size = self.Size + self.Time * 1500
	render.DrawSprite( realpos, size, size, Color( 200, 255, 200 ) )
	
	render.SetMaterial( self.Material2 )
	local size = self.Size + self.Time * 1500
	render.DrawSprite( realpos, size * 0.75, size * 0.75, Color( 10, 255, 0, 100 ) )

end