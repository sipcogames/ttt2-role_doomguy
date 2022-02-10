EFFECT.Time = 0

function EFFECT:Init( data )

	self.Material = Material( "effects/spark.vmt" )
	self.ImpactMaterial =  Material( "effects/fire_cloud2.vmt" )

	self.Pos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	self.RealPos = self:GetTracerShootPos(self.Pos, self.Weapon, self.Att )
	
	local emitter = ParticleEmitter( self.Pos )
		
		self.Tracer = emitter:Add( "particles/smokey", self.RealPos )
		self.Tracer:SetVelocity( ( self.EndPos - self.Pos ):GetNormalized()*8000 )
		self.Tracer:SetDieTime( 2 )
		self.Tracer:SetStartSize( 0.1 )
		self.Tracer:SetEndSize( 0.1 )
		self.Tracer:SetCollide( true )
		
		self.Tracer:SetCollideCallback( function( part, hitpos, hitnormal )
		
			part:SetDieTime( 0 )
		
		end )
	
	emitter:Finish()

end

function EFFECT:Think()

	self.Time = self.Time + FrameTime()
	return self.Time < 8

end

function EFFECT:Render()

	local pos1 = self.Tracer:GetPos()
	local pos2 = self.Tracer:GetPos() + self.Tracer:GetVelocity():GetNormalized()*-100
	self:SetRenderBoundsWS( pos1, pos2 )

	if self.Time > 0.02 then

		render.SetMaterial( self.Material )
		render.DrawBeam( pos2, pos1, 6, 0, 1, Color( 0, 150, 255 ) )
		
	end

	return true

end