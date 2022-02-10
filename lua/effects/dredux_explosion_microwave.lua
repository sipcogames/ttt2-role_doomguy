EFFECT.BoltMaterial = {}
for i = 0, 8 do
	EFFECT.BoltMaterial[ i ] = Material( "effects/dredux/bolt/bolt_a"..i..".png", "smooth nocull" )
end

EFFECT.GlowMaterial =  Material( "particle/particle_glow_04.vmt" )
EFFECT.ShockwaveMaterial = Material( "effects/dredux/explosion_outer_ring_02_a.png", "smooth additive nocull" )
EFFECT.ShockwaveMaterial2 =  Material( "effects/dredux/explosion_outer_ring_02.png", "smooth additive nocull" )

EFFECT.Time = 0
EFFECT.Size = math.random( 45, 60 )

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.Magnitude = data:GetMagnitude() || 3
	self.Scale = data:GetScale() || 1
	self.Entity = data:GetEntity() || NULL
	
	self:SetPos( self.Pos )
	
	self.Normal = ( -EyeVector()*5 + Vector( math.Rand(-1,1), math.Rand(-1,1), 0 ) ):GetNormalized() +  Vector( 0, 0, 1 )
	util.Effect( "StunstickImpact", data )

	local emitter = ParticleEmitter( self.Pos )

		if !IsValid( self.Entity ) || self.Entity:GetClass() ~= "proj_dmod_arbalest" then

			for i = 1, 3 do
			
				local particle = emitter:Add( "particle/smokesprites_000"..math.random( 9 ), self.Pos )
				particle:SetVelocity( VectorRand() * 60  )
				particle:SetDieTime( math.Rand( 1, 2 ) )
				particle:SetStartAlpha( 75 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 40 )
				particle:SetEndSize( 80 )
				particle:SetRoll( math.random( 0, 360 ) )
				particle:SetRollDelta( math.random( -0.4, 0.4 ) )
				particle:SetColor( 100*0.75, 200*0.75, 255*0.75 )
				particle:SetGravity( Vector(0, 0, 0 ) )
				particle:SetAirResistance( 15 )
				
			end
		
		end
	
	emitter:Finish()

end

function EFFECT:Think()

	self.Time = self.Time + FrameTime()
	return self.Time < 0.5
	
end

function EFFECT:Render()

	local normal = -EyeVector()

	if self.Time < 0.1 then
			
		local size = ( 64+self.Time*1500 )*self.Scale
		render.SetMaterial( self.GlowMaterial )
		for i = 1,2 do render.DrawQuadEasy( self.Pos, normal, size, size, Color( 0, 100, 255 ) ) end
		
	end
	
	if self.Time < 0.2 then
		
		--local size = ( 8+self.Time*2500 )*self.Scale
		--render.SetMaterial( self.ShockwaveMaterial )
		--for i = 1,2 do render.DrawQuadEasy( self.Pos, self.Normal, size, size, Color( 240, 240, 240, 150 ) ) end
		
		--

		local size = ( 8+self.Time*4000 )*self.Scale
		render.SetMaterial( self.ShockwaveMaterial2 )
		for i = 1,1 do render.DrawQuadEasy( self.Pos, normal, size, size, Color( 200, 200, 200, 100 ) ) end
		
		local size = ( 8+self.Time*2500 )*self.Scale
		render.SetMaterial( self.ShockwaveMaterial )
		for i = 1,2 do render.DrawQuadEasy( self.Pos, self.Normal, size, size, Color( 255, 255, 255, 255 ) ) end
		
		
	end
	
	return true

end





