EFFECT.Material = {}
for i = 0, 32 do
	EFFECT.Material[ i ] = Material( "effects/dredux/dexplo/exp_a"..i..".png", "smooth nocull" )
end

EFFECT.GlowMaterial = Material( "effects/dredux/flares/flare1.png", "smooth nocull" )
EFFECT.Size = math.random( 45, 60 )

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self:SetPos( self.Pos )
	
	self.Time = 0
	
	local light = DynamicLight( self:EntIndex(), false )
	light.Pos = self.Pos
	light.Size = 128
	light.Decay = 4096
	light.R = 255
	light.G = 150
	light.B = 50
	light.Brightness = 6
	light.DieTime = CurTime()+0.1
	
	local emitter = ParticleEmitter(self.Pos)
	
	for i = 1, 2 do
	
		local particle = emitter:Add( "particles/smokey",self.Pos)
		particle:SetVelocity( Vector( math.random( -20, 20 ) , math.random(-20, 20 ) , math.random( -20, 20 ) ) )
		particle:SetDieTime( math.Rand( 1, 2 ) )
		particle:SetStartAlpha( 100 )
		particle:SetEndAlpha( 10 )
		particle:SetStartSize( math.random( 30, 40 ) )
		particle:SetEndSize( math.random( 50, 80 ) )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetRollDelta( math.random( -0.2, 0.2 ) )
		particle:SetColor( 20, 20, 20 )
		particle:SetGravity( Vector(0, 0, 0 ) )
		particle:SetAirResistance( 15 )
		
	end
	
	self.MainParticle = emitter:Add( "effects/dredux/dexplo/exp_a0", self.Pos )
	self.MainParticle:SetVelocity( Vector( math.random( -20, 20 ) , math.random(-20, 20 ) , math.random( -20, 20 ) ) )
	self.MainParticle:SetDieTime( 1 )
	self.MainParticle:SetStartSize( math.random( 20, 30 ) )
	self.MainParticle:SetEndSize( math.random( 45, 50 ) )
	self.MainParticle:SetColor( 255, 255, 240 )
	self.MainParticle:SetRoll( math.random( 0, 360 ) )
	self.MainParticle:SetGravity( Vector( 0, 0, 0 ) )
	self.MainParticle:SetAirResistance( 15 )
	
	emitter:Finish()
	
	util.Effect( "cball_bounce", data )

end

function EFFECT:Think()

	self.Time = self.Time + FrameTime()
	
	local frame = math.Clamp( math.ceil( self.Time * 80 ), 0, 32 )
	self.MainParticle:SetMaterial( self.Material[ frame ] )

	return frame < 32
	
end

function EFFECT:Render()

	return true

end





