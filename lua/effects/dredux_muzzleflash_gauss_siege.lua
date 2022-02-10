EFFECT.Material = {}
for i = 1, 8 do
	EFFECT.Material[ i ] = Material( "effects/dredux/bolt/bolt_a"..i..".png", "smooth" )
end
EFFECT.Material2 = Material( "effects/dredux/ground_ripple2.png", "smooth" )

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	
	self.RealPos = self:GetTracerShootPos( self.Pos, self.Weapon, self.Att )
	
	self.Time = 0
	self.NextSprite = CurTime()
	self.CurrentSprite = math.random( 8 )
	self.Size = 50
	
	debugoverlay.Cross( self.Pos, 25, 10 )
	
end

function EFFECT:Think()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end

	self.Time = self.Time + FrameTime()
	
	if self.NextSprite < CurTime() then
	
		self:SetPos( self:GetTracerShootPos( self.Pos, self.Weapon, self.Att ) )
	
		self.CurrentSprite = math.random( 8 )
		self.NextSprite = CurTime() + 0.025
		
	end
	
	return self.Weapon:GetActiveMod()
	
end

function EFFECT:Render()

	local realpos = self:GetTracerShootPos( self.Pos, self.Weapon, 1 )

	render.SetMaterial( self.Material[ self.CurrentSprite ] )
	render.DrawSprite( realpos, self.Size, self.Size, Color( 100, 200, 255 ) )
	
end