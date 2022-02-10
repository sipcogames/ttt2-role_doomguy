function EFFECT:Init( data )
	
	self.Material = Material( "effects/doom_eternal/explosion/explosion_1.vmt", "smooth" )
	self.Material2 = Material( "effects/doom_custom/smoke/smoke_1.vmt", "smooth" )
	
	self.ShockwaveMaterial = Material( "effects/dredux/explosion_outer_ring_02.png", "smooth nocull" )
	self.GlowMaterial = Material( "particle/particle_glow_04.vmt" )
	
	self.SmokeMaterial = Material( "effects/doom_custom/smoke/smoke_2.vmt", "smooth" )
	
	self.Pos = data:GetOrigin()
	self.Scale = data:GetScale() || 1
	self.Type = data:GetFlags() || 0
	self.Magnitude = data:GetMagnitude() || 0
	
	self.Color = data:GetColor()
	if self.Color == 0 then self.Color = 255 end
	
	self:SetPos( self.Pos )
	self.Angle = math.random( 100, 260 )
	
	self.Time = 0
	
	local light = DynamicLight( self:EntIndex(), false )
	light.Pos = self.Pos
	light.Size = 128*self.Scale
	light.Decay = 4096
	light.R = 255
	light.G = 150
	light.B = 50
	light.Brightness = 4
	light.DieTime = CurTime()+0.1

	if self.Scale >= 0.75 then util.Effect( "StunstickImpact", data ) end

end

function EFFECT:Think()

	self.Time = self.Time + FrameTime()

	return self.Time < 2
	
end

function EFFECT:Render()
	
	local normal = -EyeVector()
	
		-- Smoke
	
		if self.Time < 2 && self.Scale >= 0.5 then
			
			self.Material2:SetInt( "$frame", math.Clamp( math.ceil( self.Time * 20 ), 0, 15 ) )
			
			local size = ( 200+self.Time*250 )*self.Scale
			render.SetMaterial( self.Material2 )
			for i = 1,2 do render.DrawQuadEasy( self.Pos + Vector( 0, 0, -25 )*self.Scale, normal, size, size, Color( 75, 75, 75, 255 ), 180 ) end
		
		end
		
		if self.Time < 1 && self.Scale >= 0.75 then
			
			self.SmokeMaterial:SetInt( "$frame", math.Clamp( math.ceil( self.Time * 20 ), 0, 15 ) )
			
			local size = ( 100+self.Time*100 )*self.Scale
			local alpha = math.Clamp( 255 - self.Time*600, 0, 255 )
			
			render.SetMaterial( self.SmokeMaterial )
			for i = 1,2 do render.DrawQuadEasy( self.Pos, normal, size, size, Color( 200, 200, 200, alpha ), 180 ) end
		
		end
		
		-- Glow
		
		if self.Time < 0.15 then
			
			local size = ( 64+self.Time*2000 )*self.Scale
			render.SetMaterial( self.GlowMaterial )
			render.DrawSprite( self.Pos + Vector( 0, 0, 5 ), size, size, Color( 255, 100, 0, 50 ) )
		
		end
		
		-- Core
		
		if self.Time < 0.5 then
			
			self.Material:SetInt( "$frame", math.Clamp( math.ceil( self.Time * 40 ), 0, 15 ) )
			
			local size = ( 60+self.Time*350 )*self.Scale
			render.SetMaterial( self.Material )
			for i = 1,1 do render.DrawQuadEasy( self.Pos, normal, size, size, Color( 255, 240, 220, 255 ), self.Angle ) end
		
		end

		-- shockwave
		
		if self.Time < 0.2 && self.Magnitude <= 0 then
			
			local size = ( 16+self.Time*1200 )*self.Scale
			render.SetMaterial( self.ShockwaveMaterial )
			render.DrawQuadEasy( self.Pos, normal, size, size, Color( 110, 110, 110, 200 ), 0 )
		
		end
		
		-- Detonate shockwave
		
		local normal2 = Vector( 0, 0, 1 )
		
		if self.Time < 0.2 && self.Magnitude > 0 then
			
			local size = ( 32+self.Time*1800 )*self.Scale
			render.SetMaterial( self.ShockwaveMaterial )
			render.DrawQuadEasy( self.Pos, normal2 - EyeVector()*0.1, size, size, Color( 200, 200, 200, 255 ), 0 )
		
		end
	
	
	return true

end





