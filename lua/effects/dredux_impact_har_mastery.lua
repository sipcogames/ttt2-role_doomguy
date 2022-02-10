EFFECT.Material = {}
for i = 0, 32 do
	EFFECT.Material[ i ] = Material( "effects/dredux/dexplo/exp_a"..i..".png", "smooth nocull" )
end

EFFECT.ImpactMaterial =  Material( "effects/fire_cloud2.vmt" )
EFFECT.GlowMaterial =  Material( "particle/particle_glow_04.vmt" )
EFFECT.Spark =  Material( "sprites/orangeflare1.vmt" )
EFFECT.ShockwaveMaterial = Material( "effects/dredux/explosion_outer_ring_02.png", "smooth nocull" )

EFFECT.Time = 0
EFFECT.Size = math.random( 45, 60 )

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.Magnitude = data:GetMagnitude() || 3
	self.Scale = data:GetScale() || 1
	
	self:SetPos( self.Pos )

	local emitter = ParticleEmitter( self.Pos, true )
	
		-- Glow 1
		
		local particle = emitter:Add( self.GlowMaterial, self.Pos )
		particle:SetVelocity( Vector() )
		particle:SetAngles( self.Normal:Angle() )
		particle:SetColor( 0, 150, 255 )
		particle:SetDieTime( 0.2 )
		particle:SetStartAlpha( 100 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.random( 6, 8 )*self.Scale )
		particle:SetEndSize( math.random( 10, 12 )*self.Scale )

	emitter:Finish()

	local emitter = ParticleEmitter( self.Pos, false )

		local particle = emitter:Add( self.GlowMaterial, self.Pos )
		particle:SetVelocity( Vector() )
		particle:SetColor( 0, 200, 255 )
		particle:SetDieTime( 0.2 )
		particle:SetStartAlpha( 50 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.random( 6, 8 )*self.Scale )
		particle:SetEndSize( math.random( 10, 12 )*self.Scale )

		-- Sparks
		
		for i = 1, math.random( self.Magnitude ) do
		
			local particle = emitter:Add( self.Spark, self.Pos )
			particle:SetVelocity( self.Normal*75 + VectorRand()*125 )
			particle:SetGravity( Vector( 0, 0, -400 ) )
			
			particle:SetCollide( true )
			particle:SetBounce( 0.5 )
			
			particle:SetAngles( self.Normal:Angle() )
			particle:SetColor( 0, 200, 255 )
			particle:SetDieTime( ( 0.5 + math.random()*0.5 ) * self.Magnitude*0.25 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 100 )
			
			local size = math.random()*self.Magnitude*0.33
			
			particle:SetStartSize( size )
			particle:SetEndSize( size * 2 )
			
		end
		
		for i = 1, 1 do
		
			local particle = emitter:Add( self.ShockwaveMaterial, self.Pos )
			particle:SetVelocity( Vector() )
			particle:SetDieTime( 0.1 )
			particle:SetStartSize( 25 )
			particle:SetEndSize( 100 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 100 )
			particle:SetColor( 0, 150, 255 )
			particle:SetRoll( math.random( 0, 360 ) )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetAirResistance( 15 )
			
			local particle = emitter:Add( self.ShockwaveMaterial, self.Pos )
			particle:SetVelocity( Vector() )
			particle:SetDieTime( 0.1 )
			particle:SetStartSize( 25 )
			particle:SetEndSize( 100 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 100 )
			particle:SetColor( 100, 150, 255 )
			particle:SetRoll( math.random( 0, 360 ) )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetAirResistance( 15 )
			
		end
			
	emitter:Finish()
	
	util.Effect( "MetalSpark", data )
	ParticleEffect( "d_muzzle_smoke", self.Pos + self.Normal * 5, Angle() )
	
	--[[for i = 1, 2 do
	
		local particle = emitter:Add( "particles/smokey",self.Pos)
		particle:SetVelocity( Vector( math.random( -20, 20 ) , math.random(-20, 20 ) , math.random( -20, 20 ) ) )
		particle:SetDieTime( math.Rand( 1, 2 ) )
		particle:SetStartAlpha( 200 )
		particle:SetEndAlpha( 10 )
		particle:SetStartSize( math.random( 30, 40 ) )
		particle:SetEndSize( math.random( 50, 80 ) )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetRollDelta( math.random( -0.2, 0.2 ) )
		particle:SetColor( 20, 20, 20 )
		particle:SetGravity( Vector(0, 0, 0 ) )
		particle:SetAirResistance( 15 )
		
	end]]
	
	
	
	
	--[[self.MainParticle = emitter:Add( "effects/dredux/dexplo/exp_a0", self.Pos )
	self.MainParticle:SetVelocity( Vector( math.random( -20, 20 ) , math.random(-20, 20 ) , math.random( -20, 20 ) ) )
	self.MainParticle:SetDieTime( 1 )
	self.MainParticle:SetStartSize( math.random( 20, 30 ) )
	self.MainParticle:SetEndSize( math.random( 45, 50 ) )
	self.MainParticle:SetColor( 255, 255, 240 )
	self.MainParticle:SetRoll( math.random( 0, 360 ) )
	self.MainParticle:SetGravity( Vector( 0, 0, 0 ) )
	self.MainParticle:SetAirResistance( 15 )]]
	
	--util.Effect( "cball_bounce", data )

end

function EFFECT:Think()

	self.Time = self.Time + FrameTime()
	return self.Time < 0.1
	
end

function EFFECT:Render()

	return true

end





