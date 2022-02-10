EFFECT.Time = 0
EFFECT.Alpha = 150

function EFFECT:Init( data )

	self.Material = Material( "effects/doom/mp_pistol_charged_shot.png", "smooth noclamp mips" )
	self.Material2 = Material( "effects/doom/smoke/wispy_smoke_ribbon2.png", "smooth noclamp" )
	self.GlowMaterial =  Material( "particle/particle_glow_04.vmt" )

	self.Pos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	self.RealPos = self:GetTracerShootPos(self.Pos, self.Weapon, self.Att )
	
	local emitter = ParticleEmitter( self.Pos )
		
		if IsValid( self.Weapon ) && IsValid( self.Weapon:GetOwner() ) then
		
			self.Tracer = emitter:Add( "particles/smokey", self.RealPos + self.Weapon:GetOwner():GetAimVector()*60 )
			self.Tracer:SetVelocity( ( self.EndPos - self.Pos ):GetNormalized()*7500 )
			self.Tracer:SetDieTime( 2 )
			self.Tracer:SetStartSize( 0.1 )
			self.Tracer:SetEndSize( 0.1 )
			self.Tracer:SetCollide( true )
			
			self.Tracer:SetCollideCallback( function( part, hitpos, hitnormal )
			
				part:SetDieTime( 0 )
			
			end )
		
		end
	
	emitter:Finish()

end

function EFFECT:Think()

	self.Time = self.Time + FrameTime()
	return self.Time < 8

end

function EFFECT:Render()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end

	if !self.Tracer || self.Tracer:GetDieTime() <= 0 then return end

	local pos1 = self.Tracer:GetPos()
	
	local dist = math.Clamp( self.Tracer:GetPos():Distance( self.Pos ), 400, 600 )
	local pos2 = self.Tracer:GetPos() + self.Tracer:GetVelocity():GetNormalized()*-dist
	
	self:SetRenderBoundsWS( pos1, pos2 )

	if self.Time > 0.015 then

		self.Alpha = self.Alpha - self.Time*20
				
		local size = 16
		render.SetMaterial( self.GlowMaterial )
		render.DrawSprite( pos1, size, size, Color( 255, 180, 0, 10 ) )
		
		render.SetMaterial( self.Material )
		render.DrawBeam( pos1, pos2, 3, 0, 1, Color( 255, 255, 240 ) )
		
	end

	return true

end