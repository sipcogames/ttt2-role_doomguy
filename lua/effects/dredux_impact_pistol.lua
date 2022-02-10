EFFECT.ImpactMaterial =  Material( "effects/strider_muzzle.png" )
EFFECT.GlowMaterial =  Material( "particle/particle_glow_04.vmt" )
EFFECT.Spark =  Material( "sprites/orangeflare1.vmt" )

EFFECT.Time = 0
EFFECT.Size = math.random( 45, 60 )

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.Magnitude = data:GetMagnitude() || 3
	self.Scale = data:GetScale() || 1
	self.Color = data:GetColor() || 255
	
	self:SetPos( self.Pos )

	local emitter = ParticleEmitter( self.Pos, true )
	
	-- Main
	
	local particle = emitter:Add( self.ImpactMaterial, self.Pos )
	particle:SetVelocity( Vector() )
	particle:SetAngles( self.Normal:Angle() )
	particle:SetColor( 100, 200, 255 )
	particle:SetDieTime( 0.15 )
	particle:SetStartAlpha( 255 )
	particle:SetEndAlpha( 0 )
	particle:SetStartSize( math.random( 2, 3 )*self.Scale )
	particle:SetEndSize( math.random( 4, 5 )*self.Scale )
	
	emitter:Finish()
	
	local emitter = ParticleEmitter( self.Pos, false )

	-- Glow 2

	local particle = emitter:Add( self.GlowMaterial, self.Pos )
	particle:SetVelocity( Vector() )
	particle:SetAngles( self.Normal:Angle() )
	particle:SetColor( 50, 200, 255 )
	particle:SetDieTime( 0.2 )
	particle:SetStartAlpha( 25 )
	particle:SetEndAlpha( 0 )
	particle:SetStartSize( math.random( 3, 4 )*self.Scale )
	particle:SetEndSize( math.random( 5, 6 )*self.Scale )

	
	emitter:Finish()
end

function EFFECT:Think()

	self.Time = self.Time + FrameTime()
	return self.Time < 0.1
	
end

function EFFECT:Render()

	return true

end





