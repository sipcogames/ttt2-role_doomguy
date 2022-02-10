EFFECT.Material = {}
for i = 1, 8 do
	EFFECT.Material[ i ] = Material( "effects/dredux/bolt/bolt_a"..i..".png", "smooth" )
end

EFFECT.Time = 0
EFFECT.NextSprite = CurTime()
EFFECT.CurrentSprite = 1
EFFECT.Size = 17.5

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	self.RealPos = self:GetTracerShootPos( self.Pos, self.Weapon, self.Att )
	
	debugoverlay.Cross( self.Pos, 25, 10 )
	
end

function EFFECT:Think()

	if !IsValid( self.Weapon ) then return false end

	self.Time = self.Time + FrameTime()
	
	if self.NextSprite < CurTime() then
	
		self:SetPos( self:GetTracerShootPos( self.Pos, self.Weapon, self.Att ) )
	
		self.CurrentSprite = math.random( 8 )
		self.NextSprite = CurTime() + 0.05
		
	end
	
	if self.Time > 0.1 then
		return self.Weapon:GetNWBool( "ActiveWeapon", false )
	else
		return true
	end
	
end

function EFFECT:Render()

	local realpos = self:GetTracerShootPos( self.Pos, self.Weapon,  self.Att )

	render.SetMaterial( self.Material[ self.CurrentSprite ] )
	
	render.DrawSprite( realpos, self.Size, self.Size, Color( 50, 255, 0 ) )
	render.DrawSprite( realpos, self.Size, self.Size, Color( 50, 255, 0 ) )
	
end