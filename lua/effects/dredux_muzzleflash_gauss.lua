EFFECT.Material = Material( "effects/dredux/muzzle/muzzle_a2.png", "smooth" )
EFFECT.Material2 = Material( "effects/dredux/ground_ripple2.png", "smooth" )

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	
	self.RealPos = self:GetTracerShootPos( self.Pos, self.Weapon, 1 )
	self.RealPos2 = self:GetTracerShootPos( self.Pos, self.Weapon, 2 )
	
	self.Time = 0
	self.Size = 40
	
	debugoverlay.Cross( self.Pos, 25, 10 )
	
	local muzzlelight = DynamicLight( self:EntIndex(), false )
	muzzlelight.Pos = self.RealPos2
	muzzlelight.Size = 256
	muzzlelight.Decay = 4096
	muzzlelight.R = 50
	muzzlelight.G = 200
	muzzlelight.B = 255
	muzzlelight.Brightness = 8
	muzzlelight.DieTime = CurTime() + 0.1
	
end


function EFFECT:Think()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end 
	
	self.Time = self.Time + FrameTime()
	return self.Time < 0.075
	
end

function EFFECT:Render()

	local realpos = self:GetTracerShootPos( self.Pos, self.Weapon, 1 )

	local size = self.Size + self.Time * 1024

	render.SetMaterial( self.Material )
	render.DrawSprite( realpos, size, size)
	
	render.SetMaterial( self.Material2 )
	render.DrawSprite( realpos, size*2, size*2,  Color( 100, 200, 255, 100 ))
	
end