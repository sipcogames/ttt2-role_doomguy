EFFECT.Material = {}
for i = 0, 8 do
	EFFECT.Material[ i ] = Material( "effects/dredux/bolt/bolt_a"..i..".png", "smooth nocull" )
end

EFFECT.ShockwaveMaterial = Material( "effects/dredux/explosion_outer_ring_02.png", "smooth nocull" )
EFFECT.ShockwaveMaterial2 = Material( "effects/doom_eternal/shockwave_lightning.png", "smooth nocull" )

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	
	self.Time = 0
	self.Alpha = 255
	
	self.SphereSize = 10
	self.SphereAlpha = 100
	
	local emitter = ParticleEmitter( self.Pos )
	
		for i = 1,5 do
		
			local particle = emitter:Add( self.ShockwaveMaterial, self.Pos )
			particle:SetVelocity( Vector() )
			particle:SetDieTime( 0.15 )
			particle:SetStartSize( 8 )
			particle:SetEndSize( 100 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 100 )
			particle:SetColor( 255, 75, 25 )
			particle:SetRoll( math.random( 0, 360 ) )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			
		end
		
		for i = 1, 1 do
		
			local particle = emitter:Add( self.ShockwaveMaterial2, self.Pos )
			particle:SetVelocity( Vector() )
			particle:SetDieTime( 0.15 )
			particle:SetStartSize( 8 )
			particle:SetEndSize( 100 )
			particle:SetStartAlpha( 75 )
			particle:SetEndAlpha( 25 )
			particle:SetColor( 255, 25, 0 )
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