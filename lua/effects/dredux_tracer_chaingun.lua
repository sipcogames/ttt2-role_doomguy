EFFECT.Time = 0
EFFECT.Alpha = 150

function EFFECT:Init( data )

	self.Material = Material( "effects/spark.vmt" )
	self.Material2 = Material( "effects/doom/smoke/wispy_smoke_ribbon2.png", "smooth noclamp" )

	self.Pos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	self.RealPos = self:GetTracerShootPos(self.Pos, self.Weapon, self.Att )
	
	local emitter = ParticleEmitter( self.RealPos )
		
	if IsValid( self.Weapon ) && IsValid( self.Weapon:GetOwner() ) then
		
		if !isfunction( self.Weapon.GetSelectedMod ) then return end
		
		if ( self.Weapon:GetSelectedMod() == 1 ) || self.Weapon:GetClass() == "weapon_dredux_de_chaingun" then self.UraniumCoating = true else self.UraniumCoating = false end
		self.Alpha = self.UraniumCoating && 50 || 150
		
		self.Tracer = emitter:Add( "particles/smokey", self.RealPos + self.Weapon:GetOwner():GetAimVector()*60 )
		self.Tracer:SetVelocity( ( self.EndPos - self.Pos ):GetNormalized()* ( self.UraniumCoating && 7500 || 10000 ) )
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

	if !self.Tracer then return end

	local col = self.UraniumCoating && Color( 0, 125, 255 ) || Color( 255, 200, 100 )

	local pos1 = self.Tracer:GetPos()
	local pos2 = self.Tracer:GetPos() + self.Tracer:GetVelocity():GetNormalized()*-150
	
	local dist = math.Clamp( self.Tracer:GetPos():Distance( self.Pos ), 50, 200 )
	
	local pos3 = self.Tracer:GetPos() + self.Tracer:GetVelocity():GetNormalized()*-dist
	
	self:SetRenderBoundsWS( pos1, pos2 )

	if self.Time > 0.01 then

		self.Alpha = 255 - self.Time*20
		
		if !self.UraniumCoating then
		
			render.SetMaterial( self.Material2 )
			render.DrawBeam( pos3, pos1, 4, 0, dist/900, Color( 150, 150, 150, self.Alpha ) )
		
		end
		
		render.SetMaterial( self.Material )
		render.DrawBeam( pos2, pos1, self.UraniumCoating && 10 || 6, 0, 1, col )
		render.DrawBeam( pos2, pos1, self.UraniumCoating && 10 || 6, 0, 1, col )
		
		
	end

	return true

end