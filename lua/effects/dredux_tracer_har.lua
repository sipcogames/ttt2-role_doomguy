EFFECT.Time = 0
EFFECT.Alpha = 150

function EFFECT:Init( data )

	self.Material = Material( "effects/spark.vmt" )
	self.Material2 = Material( "effects/doom/smoke/wispy_smoke_ribbon2.png", "smooth noclamp" )

	self.Pos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self.Random = math.random( 50, 100 ) * 0.01
	
	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end

	self:SetPos( self.Pos )
	self.RealPos = self:GetTracerShootPos(self.Pos, self.Weapon, self.Att )
	
	self.Scoped = self.Weapon.GetActiveMod && self.Weapon:GetActiveMod()
	
	local emitter = ParticleEmitter( self.Pos )
		
			local vel = self.Scoped && 20000 || 12500
		
			self.Tracer = emitter:Add( "particles/smokey", self.RealPos + self.Weapon:GetOwner():GetForward()*60 )
			self.Tracer:SetVelocity( ( self.EndPos - self.Pos ):GetNormalized()*vel )
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
	return self.Time < 5

end

function EFFECT:Render()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end

	local pos1

	if self.Tracer then 

		pos1 = self.Tracer:GetPos()
		local pos2 = self.Tracer:GetPos() + self.Tracer:GetVelocity():GetNormalized()*-300
		
		local dist = math.Clamp( self.Tracer:GetPos():Distance( self.Pos ), 0, self.Scoped && 1000 || 400 )
		
		local pos3 = self.Tracer:GetPos() + self.Tracer:GetVelocity():GetNormalized()*-dist
		
		self:SetRenderBoundsWS( pos1, pos2 )

		if self.Time > 0.02 then
			
			render.SetMaterial( self.Material )
			render.DrawBeam( pos2, pos1, 6, 0, 1, Color( 255, 200, 100 ) )
			
		end
	
	end
	
	local decrease = self.Scoped && 20 || 40
	self.Alpha = self.Alpha - self.Time*decrease
	
	local pos2 = pos1 || self.EndPos
	local dist = ( self.RealPos - pos2 ):Length()
	
	render.SetMaterial( self.Material2 )
	render.DrawBeam( self.RealPos, pos1 || self.EndPos, 1 + self.Time*64, 0, dist/120 * self.Random, Color( 200, 200, 200, math.Clamp( 100-self.Time*1000, 0, 150 ) ) )

	return true

end