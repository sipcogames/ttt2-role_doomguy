EFFECT.Material = {}
for i = 0, 8 do
	EFFECT.Material[ i ] = Material( "effects/dredux/bolt/bolt_a"..i..".png", "smooth nocull" )
end

EFFECT.ShockwaveMaterial = Material( "effects/dredux/explosion_outer_ring_02_b.png", "smooth additive nocull" )
EFFECT.ShockwaveMaterial2 = Material( "effects/doom_eternal/shockwave_lightning.png", "smooth nocull" )

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	
	self.Time = 0
	self.Alpha = 255
	
	self.SphereSize = 10
	self.SphereAlpha = 100
	
	util.Effect( "StunstickImpact", data )
	
	local light = DynamicLight( self:EntIndex(), false )
	light.Pos = self.Pos
	light.Size = 512
	light.Decay = 512
	light.R = 255
	light.G = 150
	light.B = 0
	light.Brightness = 1
	light.DieTime = CurTime()+0.1
	
	local emitter = ParticleEmitter( self.Pos )
	
	local particle = emitter:Add( "particle/warp2_warp", self.Pos )
	particle:SetVelocity( Vector() )
	particle:SetDieTime( 0.25 )
	particle:SetStartAlpha( 100 )
	particle:SetEndAlpha( 100 )
	particle:SetStartSize( 200 )
	particle:SetEndSize( 0 )
	particle:SetColor( 255, 255, 255 )
	particle:SetGravity( Vector(0, 0, 0 ) )
	particle:SetAirResistance( 15 )
	
	for i = 1, 5 do
	
		local particle = emitter:Add( "particle/smokesprites_000"..math.random( 9 ), self.Pos )
		particle:SetVelocity( Vector( math.random( -200, 200 ), math.random( -200, 200 ), 0 ) )
		particle:SetDieTime( math.Rand( 1, 2 ) )
		particle:SetStartAlpha( 50 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 60 )
		particle:SetEndSize( 120 )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetRollDelta( math.random( -0.4, 0.4 ) )
		particle:SetColor( 255, 100, 0 )
		particle:SetGravity( Vector(0, 0, 0 ) )
		particle:SetAirResistance( 15 )
		
	end
	
	for i = 1, 10 do
	
		local particle = emitter:Add( self.Material[ math.random( 8 ) ], self.Pos )
		particle:SetVelocity( VectorRand() * 120 )
		particle:SetDieTime( math.Rand( 1, 2 ) - 1 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 10 )
		particle:SetEndSize( 30 )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetRollDelta( math.random( -0.4, 0.4 ) )
		particle:SetColor( 255, 150, 50 )
		particle:SetGravity( Vector(0, 0, 0 ) )
		particle:SetAirResistance( 15 )
		
	end
	
	for i = 1,2 do
	
		local particle = emitter:Add( self.ShockwaveMaterial2, self.Pos )
		particle:SetVelocity( Vector() )
		particle:SetDieTime( 0.2 )
		particle:SetStartSize( 8 )
		particle:SetEndSize( 150 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 100 )
		particle:SetColor( 255, 100, 50 )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetGravity( Vector( 0, 0, 0 ) )
	
		local particle = emitter:Add( self.ShockwaveMaterial, self.Pos )
		particle:SetVelocity( Vector() )
		particle:SetDieTime( 0.2 )
		particle:SetStartSize( 8 )
		particle:SetEndSize( 150 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 100 )
		particle:SetColor( 255, 255, 255 )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetGravity( Vector( 0, 0, 0 ) )
		
	end
	
	
	emitter:Finish()

end

function EFFECT:Think()

	if !self.Time then self.Time = 0 end
	self.Time = self.Time + FrameTime()
	self.SphereSize = self.SphereSize + self.Time * 60
	
	self.SphereAlpha = math.Clamp( self.SphereAlpha - self.Time * 32, 0, 255 )
	
	return self.Time < 1

end

function EFFECT:Render()

	render.SetColorMaterial()
	--render.DrawSphere( self.Pos, self.SphereSize, 20, 20, Color( 10, 255, 0, self.SphereAlpha ) )

	return true

end