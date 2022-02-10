EFFECT.BeamMaterial = Material( "effects/dredux/beam/beam_02.png", "smooth" )
EFFECT.SiegeMaterial = Material( "effects/dredux/siege_shockwave.png", "smooth noclamp" )
EFFECT.ShockwaveMaterial = Material( "effects/dredux/explosion_outer_ring_02_a.png", "smooth nocull additive" )
EFFECT.ShockwaveMaterial2 = Material( "effects/dredux/explosion_outer_ring_02_b.png", "smooth nocull additive" )

EFFECT.GaussImpact = Material( "effects/doom/energy.png", "smooth nocull" )
EFFECT.BallistaImpact = Material( "effects/doom_custom/muzzleflare.png", "smooth nocull" )

function EFFECT:Init( data )

	self.Pos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	self.RealPos = self:GetTracerShootPos(self.Pos, self.Weapon, self.Att )
	
	self.Time = 0
	self.TextureEnd = ( self.Pos - self.EndPos ):Length() * 0.001
	
	self.TrailSize = 10
	self.Alpha = 255
	
	self.SphereSize = 10
	self.SphereAlpha = 64
	
	if !IsValid( self.Weapon ) then return end
	
	self.Siege = self.Weapon:GetSelectedMod() == 2 && self.Weapon:GetActiveMod()
	
	self.IsBallista = self.Weapon:GetClass() == "weapon_dredux_de_gauss"
	
	self.col = self.IsBallista && Color( 255, 150, 50 ) || Color( 50, 200, 255 )
	
	local data = EffectData()
	data:SetOrigin( self.EndPos )
	util.Effect( "StunstickImpact", data )
	util.Effect( "StunstickImpact", data )
	
	local light = DynamicLight( self.Weapon:EntIndex(), false )
	light.Pos = self.EndPos
	light.Size = 512
	light.Decay = 4096
	light.R = self.col.r
	light.G = self.col.g
	light.B = self.col.b
	light.Brightness = 2
	light.DieTime = CurTime()+0.05
	
	local emitter = ParticleEmitter( self.EndPos )
	
	for i = 1,3 do
	
		local particle = emitter:Add( "particle/smokesprites_000"..math.random( 9 ), self.EndPos )
		particle:SetVelocity( Vector( math.random( -60, 60 ) , math.random(-60, 60 ) , math.random( -60, 60 ) ) )
		particle:SetDieTime( math.Rand( 1, 2 ) )
		particle:SetStartAlpha( 30 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.random( 80, 90 ) )
		particle:SetEndSize( math.random( 125, 140 ) )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetRollDelta( math.random( -0.4, 0.4 ) )
		particle:SetColor( self.col:Unpack() )
		particle:SetGravity( Vector(0, 0, 0 ) )
		particle:SetAirResistance( 15 )
		
	end
	
	if self.IsBallista then
	
		local particle = emitter:Add( self.BallistaImpact, self.EndPos )
		particle:SetVelocity( Vector() )
		particle:SetDieTime( 0.15 )
		particle:SetStartSize( 8 )
		particle:SetEndSize( 125 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 50 )
		particle:SetColor( 255, 175, 75 )
		particle:SetGravity( Vector( 0, 0, 0 ) )
	
		local particle = emitter:Add( self.ShockwaveMaterial2, self.EndPos )
		particle:SetVelocity( Vector() )
		particle:SetDieTime( 0.1 )
		particle:SetStartSize( 8 )
		particle:SetEndSize( 100 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 100 )
		--particle:SetColor( self.col:Unpack() )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetGravity( Vector( 0, 0, 0 ) )
	
	else
		
		for i = 1, 2 do 
			local particle = emitter:Add( self.GaussImpact, self.EndPos )
			particle:SetVelocity( Vector() )
			particle:SetDieTime( 0.15 )
			particle:SetStartSize( 8 )
			particle:SetEndSize( 80 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 100 )
			particle:SetColor( 255, 255, 255 )
			particle:SetRoll( math.random( 45 ) + 180*i )
			particle:SetGravity( Vector( 0, 0, 0 ) )
		end
		
		local particle = emitter:Add( self.ShockwaveMaterial, self.EndPos )
		particle:SetVelocity( Vector() )
		particle:SetDieTime( 0.1 )
		particle:SetStartSize( 8 )
		particle:SetEndSize( 125 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 100 )
		--particle:SetColor( self.col:Unpack() )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetGravity( Vector( 0, 0, 0 ) )
		
	end
	
	if self.Siege then
	
		local dir = self.EndPos - self.Pos
		local dir_n = dir:GetNormalized()
		local length = dir:Length()
		
		for i = 1, math.Clamp( math.floor( length / 175 ), 1, 100 ) do
		
			local particle = emitter:Add( self.SiegeMaterial, self.RealPos + dir_n * i * 175 )
			particle:SetVelocity( VectorRand() )
			particle:SetDieTime( math.random( 24, 26 ) * 0.01 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 100 )
			particle:SetStartSize( 25 )
			particle:SetEndSize( 100 )
			particle:SetRoll( math.random( 0, 360 ) )
			particle:SetRollDelta( math.random( -1, 1 ) )
			particle:SetColor( 50, 200, 255 )
			particle:SetGravity( Vector(0, 0, 0 ) )
			particle:SetAirResistance( 15 )
		
		end
	
	end
	
	emitter:Finish()

end

function EFFECT:Think()

	if !self.Time then self.Time = 0 end
	self.Time = self.Time + FrameTime()
	
	self.TrailSize = self.TrailSize + self.Time * 80
	self.SphereSize = self.SphereSize + self.Time * 90
	
	self.SphereAlpha = math.Clamp( self.SphereAlpha - self.Time * 120, 0, 255 )
	
	local decrease = self.Siege && 80 || 160
	self.Alpha = math.Clamp( self.Alpha - self.Time*decrease, 0, 255 )
	
	return self.Time < 5

end

function EFFECT:Render()

	render.SetMaterial( self.BeamMaterial )
	for i = 1, 5 do render.DrawBeam( self.RealPos, self.EndPos, self.TrailSize, 0, self.TextureEnd, Color( self.col.r, self.col.g, self.col.b, self.Alpha ) ) end
	
	render.SetColorMaterial()
	render.DrawSphere( self.EndPos, self.SphereSize, 20, 20, Color( self.col.r, self.col.g, self.col.b, self.SphereAlpha ) )

	return true

end