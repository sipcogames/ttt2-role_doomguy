EFFECT.BoltMaterial = {}
for i = 0, 8 do
	EFFECT.BoltMaterial[ i ] = Material( "effects/dredux/bolt/bolt_a"..i..".png", "smooth nocull" )
end

EFFECT.GlowMaterial =  Material( "particle/particle_glow_04.vmt" )
EFFECT.ShockwaveMaterial = Material( "effects/dredux/explosion_outer_ring_02_a.png", "smooth nocull additive" )

EFFECT.Time = 0
EFFECT.Size = math.random( 45, 60 )

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.Magnitude = data:GetMagnitude() || 3
	self.Scale = data:GetScale() || 1
	self.Entity = data:GetEntity() || NULL
	
	self:SetPos( self.Pos )
	
	self.Normal = ( -EyeVector()*5 + Vector( math.Rand(-1,1), math.Rand(-1,1), 0 ) ):GetNormalized() +  Vector( 0, 0, 0.5 )
	util.Effect( "StunstickImpact", data )

	local data = EffectData()
	data:SetOrigin( self:GetPos() )
	data:SetColor( 255 )
	data:SetMagnitude( 0 )
	data:SetScale( 0.5 )
	util.Effect( "dredux_explosion", data, nil, true )

end

function EFFECT:Think()

	self.Time = self.Time + FrameTime()
	return self.Time < 0.5
	
end

function EFFECT:Render()

	local normal = -EyeVector()

	if self.Time < 0.1 then
			
		local size = ( 64+self.Time*1000 )*self.Scale
		render.SetMaterial( self.GlowMaterial )
		for i = 1,2 do render.DrawQuadEasy( self.Pos, normal, size, size, Color( 255, 100, 0 ) ) end
		
	end
	
	if self.Time < 0.15 then
		
		--

		local size = ( 8+self.Time*3000 )*self.Scale
		render.SetMaterial( self.ShockwaveMaterial )
		for i = 1,1 do render.DrawQuadEasy( self.Pos, normal, size, size, Color( 255, 255, 255, 255 ) ) end
		
		
	end
	
	return true

end





