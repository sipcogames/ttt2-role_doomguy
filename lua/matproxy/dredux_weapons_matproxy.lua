AddCSLuaFile()

local HDREnabled = render.GetHDREnabled()

matproxy.Add({

	name = "dredux_TurretHeat",
	init = function( self, mat, values )
		self.ResultTo = values.resultvar
	end,
	bind = function( self, mat, ent )
		if !IsValid( ent ) || !IsValid( ent:GetOwner() ) then return end
		local heat = ent:GetOwner():GetActiveWeapon():GetBarrelHeat()
		mat:SetFloat( self.ResultTo, heat * 2 - 0.5 )
	end
	
})

matproxy.Add({

	name = "dredux_PlasmaHeat",
	init = function( self, mat, values )
	end,
	bind = function( self, mat, ent )
		if !IsValid( ent:GetOwner() ) || !ent:GetOwner():GetActiveWeapon().GetOverHeated then return end
		local heat = ent:GetOwner():GetActiveWeapon():GetOverHeated() && 1.5 || ( ent:GetOwner():GetActiveWeapon():GetHeat()/10 )
		
		if heat < 0.5 then
			mat:SetVector( "$emissiveBlendTint", Vector( 0.25, 0.5, 2 ) )
		else
			mat:SetVector( "$emissiveBlendTint", Vector( 0.25+(heat-0.5)*4, 0.5-(heat-0.5)*0.8, 2-(heat-0.5)*4 ) )
		end
			
		mat:SetFloat( "$emissiveBlendStrength", math.Clamp( heat^2, 0.5, 1 ) )
		
	end
	
})

matproxy.Add({

	name = "dredux_Reflection",
	
	init = function( self, mat, values )
	
		self.ResultTo = "$envmaptint"
		self.Power = mat:GetFloat( "$ReflectionPower" )
		
		self.Tint = mat:GetVector( "$ReflectionTint" )
		
		self.Min = mat:GetFloat( "$ReflectionMin" )
		self.Max = mat:GetFloat( "$ReflectionMax" )
		
		self.HDRMul = mat:GetFloat( "$ReflectionHDR" )
		self.LDRMul = mat:GetFloat( "$ReflectionLDR" )
		
		self.Result = 0
		
		--self.DefaultReflection = mat:GetString( "$envmap" )
		--self.UseDefaultReflection = !GetConVar( "cl_dredux_reflections_env_cubemap" ):GetBool()
		
	end,
	
	bind = function( self, mat, ent )
	
		if !IsValid( ent ) then return end
		
		local ply = LocalPlayer()
		if !GetConVar( "cl_dredux_reflections" ):GetBool() then
			mat:SetVector( self.ResultTo, Vector( 0, 0, 0 ) )
			return 
		end
		
		local light = render.GetLightColor( ent:GetPos() )
		
		local tint = ( light.r + light.g + light.b ) * 0.333

		if !self.Power then self.Power = 1 end
		--tint = tint * self.Power

		local result
		
		if HDREnabled then
			tint = tint * self.HDRMul
		else
			tint = tint * self.LDRMul
		end
		
		self.Result = Lerp( FrameTime() * 5, self.Result, tint)
		
		local result = math.Clamp( self.Result, self.Min, self.Max)
		local mul = HDREnabled && light*light * 0.8 || light*light * 1.5
		
		if self.Tint then
		
			result = self.Tint * result * self.Power * mul
		
		else
		
			result = Vector( result, result, result ) * self.Power * mul
			
		end
		
		result.r = math.Clamp( result.r, self.Min, self.Max)
		result.g = math.Clamp( result.g, self.Min, self.Max)
		result.b = math.Clamp( result.b, self.Min, self.Max)
		
		mat:SetVector( self.ResultTo, result )
		
	end
	
})

matproxy.Add({

	name = "dredux_WeaponParticleOneShot",
	
	init = function( self, mat, values )
		self.EndFrame = mat:GetFloat( "$endframe" ) 
		self.Rate = mat:GetFloat( "$animspeed" )
		mat:SetInt( "$frame", 1 )
	end,
	
	bind = function( self, mat, ent )
		self.Time = self.Time + FrameTime()
		mat:SetInt( "$frame", math.Clamp( math.ceil( self.Time * self.Rate ), 0, self.EndFrame ) )
	end
	
})