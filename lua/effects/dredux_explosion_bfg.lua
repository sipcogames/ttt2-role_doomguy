EFFECT.Material = {}
for i = 0, 8 do
	EFFECT.Material[ i ] = Material( "effects/dredux/bolt/bolt_a"..i..".png", "smooth nocull" )
end

EFFECT.ShockwaveMaterial = Material( "effects/dredux/explosion_outer_ring_02_c.png", "smooth nocull" )
EFFECT.ShockwaveMaterial2 = Material( "effects/doom_eternal/shockwave_lightning.png", "smooth nocull" )

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	
	self.Time = 0
	self.Alpha = 255
	
	self.SphereSize = 10
	self.SphereAlpha = 100
	
	util.Effect( "StunstickImpact", data )
	util.Effect( "StunstickImpact", data )
	
	local light = DynamicLight( self:EntIndex(), false )
	light.Pos = self.Pos
	light.Size = 1024
	light.Decay = 1024
	light.R = 10
	light.G = 200
	light.B = 0
	light.Brightness = 1
	light.DieTime = CurTime()+0.1
	
	local emitter = ParticleEmitter( self.Pos )
	
	local particle = emitter:Add( "particle/warp2_warp", self.Pos )
	particle:SetVelocity( Vector() )
	particle:SetDieTime( 0.25 )
	particle:SetStartAlpha( 255 )
	particle:SetEndAlpha( 255 )
	particle:SetStartSize( math.random( 135, 160 ) )
	particle:SetEndSize( math.random( 0, 0 ) )
	particle:SetRoll( math.random( 0, 360 ) )
	particle:SetRollDelta( math.random( -0.4, 0.4 ) )
	particle:SetColor( 255, 255, 255 )
	particle:SetGravity( Vector(0, 0, 0 ) )
	particle:SetAirResistance( 15 )
	
	for i = 1, 2 do
	
		local particle = emitter:Add( "particle/smokesprites_000"..math.random( 9 ), self.Pos )
		particle:SetVelocity( VectorRand() * 40  )
		particle:SetDieTime( math.Rand( 1, 2 ) )
		particle:SetStartAlpha( 100 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.random( 50, 60 ) )
		particle:SetEndSize( math.random( 70, 80 ) )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetRollDelta( math.random( -0.4, 0.4 ) )
		particle:SetColor( 100, 255, 100 )
		particle:SetGravity( Vector(0, 0, 0 ) )
		particle:SetAirResistance( 15 )
		
	end
	
	for i = 1, 1 do
	
		local particle = emitter:Add( self.Material[ math.random( 8 ) ], self.Pos )
		particle:SetVelocity( VectorRand() * 20 )
		particle:SetDieTime( math.Rand( 1, 2 ) - 1 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.random( 40, 60 ) )
		particle:SetEndSize( math.random( 70, 80 ) )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetRollDelta( math.random( -0.4, 0.4 ) )
		particle:SetColor( 10, 255, 0 )
		particle:SetGravity( Vector(0, 0, 0 ) )
		particle:SetAirResistance( 15 )
		
	end
	
	for i = 1,5 do
	
		local particle = emitter:Add( self.ShockwaveMaterial, self.Pos )
		particle:SetVelocity( Vector() )
		particle:SetDieTime( 0.15 )
		particle:SetStartSize( 8 )
		particle:SetEndSize( 200 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 100 )
		--particle:SetColor( 200, 255, 75 )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetGravity( Vector( 0, 0, 0 ) )
		
	end
	
	--[[for i = 1,1 do
	
		local particle = emitter:Add( self.ShockwaveMaterial2, self.Pos )
		particle:SetVelocity( Vector() )
		particle:SetDieTime( 0.15 )
		particle:SetStartSize( 8 )
		particle:SetEndSize( 200 )
		particle:SetStartAlpha( 200 )
		particle:SetEndAlpha( 100 )
		particle:SetColor( 100, 255, 50 )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetGravity( Vector( 0, 0, 0 ) )
		
	end]]
	
	
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
	
	local size = self.Time * 1500
	render.DrawSphere( self.Pos, size, 20, 20, Color( 50, 255, 0, math.Clamp( 200 - self.Time * 1024, 0, 255 ) ) )

	return true

end