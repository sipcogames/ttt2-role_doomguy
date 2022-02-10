EFFECT.ImpactMaterial =  Material( "effects/fire_cloud2.vmt" )
EFFECT.GlowMaterial =  Material( "particle/particle_glow_04.vmt" )
EFFECT.Freeze = Material( "effects/doom_custom/freeze.png", "smooth nocull" )

EFFECT.ShockwaveMaterial2 = Material( "effects/dredux/explosion_outer_ring_02_a.png", "smooth nocull" )

EFFECT.Time = 0
EFFECT.Size = math.random( 45, 60 )

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()
	
	self:SetPos( self.Pos )
	
	local emitter = ParticleEmitter( self.Pos, false )

		-- Bolt

		for i = 1, 8 do

			local particle = emitter:Add( "particle/smokesprites_000"..math.random( 9 ), self.Pos )
			particle:SetVelocity( VectorRand()*50 )
			
			particle:SetColor( 100, 200, 255 )
			particle:SetDieTime( math.Rand(1,4) )
			particle:SetStartAlpha( 100 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.random( 25, 25 )*2 )
			particle:SetEndSize( math.random( 50, 75 )*2 )
			
			
			
			local particle = emitter:Add( self.GlowMaterial, self.Pos )
			
			particle:SetVelocity( VectorRand()*100 )
			particle:SetGravity( Vector( 0, 0, -400 ) )
			
			particle:SetCollide( true )
			particle:SetBounce( 0.5 )
			
			particle:SetColor( 50, 150, 255 )
			particle:SetDieTime( 0.15 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.random( 18, 22 ) )
			particle:SetEndSize( math.random( 24, 28 ) )
		
		end
		
		-- Glow
		
		local particle = emitter:Add( self.GlowMaterial, self.Pos )
		particle:SetVelocity( Vector() )
		particle:SetColor( 100, 200, 255 )
		particle:SetDieTime( 0.2 )
		particle:SetStartAlpha( 75 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 32 )
		particle:SetEndSize( 64 )

		-- Sparks
		
	emitter:Finish()
	
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
	return self.Time < 1
	
end

function EFFECT:Render()

	local normal = -EyeVector()

	if self.Time < 0.2 then
			
		local size = ( self.Time*2500 )
		render.SetMaterial( self.ShockwaveMaterial2 )
		render.DrawQuadEasy( self.Pos, normal, size, size, Color( 255, 255, 255, 200 ) )
		
	end
	
	--render.SetColorMaterial()
	
	render.SetMaterial( self.Freeze )
	
	local size = self.Time * 750
	render.DrawSphere( self.Pos, size, 20, 20, Color( 175, 220, 255, math.Clamp( 200 - self.Time * 650, 0, 255 ) ) )
	
	return true

end





