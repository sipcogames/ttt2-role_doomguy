
-- DOOM Pistol muzzleflash effect

EFFECT.Material = Material( "effects/doom_eternal/muzzleflash/muzzle_b2.png", "smooth" )
EFFECT.Material2 = Material( "effects/doom/plasma_ball.png", "smooth" )
EFFECT.Material3 = Material( "effects/doom_custom/flare/flare_1.vmt" )

EFFECT.Time = 0

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	
	
	self:SetPos( self.Pos )
	self.Angle = math.random( 360 )
	
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )
	
	util.Effect( "dredux_muzzlelight_a", data )
	
end

function EFFECT:Think()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end 

	if !self.Time then self.Time = 0 end
	self.Time = self.Time + FrameTime()
	
	return self.Time < 0.075
	
end

function EFFECT:Render()

	local realpos = self:GetTracerShootPos( self.RealPos, self.Weapon, self.Att )
	
	if IsValid( self.Weapon ) then
		
		self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )

		local normal = -EyeVector()
		
		self:SetPos( realpos )
		
		local size = ( self.IsViewModelEffect && ( self.Time * 750 ) || ( self.Time * 300 ) )
		render.SetMaterial( self.Material )
		render.DrawQuadEasy( realpos, normal, size, size,Color( 50, 100, 255 ), self.Angle )
		
		if !self.IsViewModelEffect then
		
			local size = 2 + self.Time * 150
			render.SetMaterial( self.Material2 )
			render.DrawQuadEasy( realpos, normal, size, size,Color( 50, 150, 255, 255 ), self.Angle )
			
		else
		
			local size = 16 + self.Time * 300
			render.SetMaterial( self.Material2 )
			render.DrawQuadEasy( realpos, normal, size, size,Color( 25, 100, 255 ), self.Angle )
			render.DrawQuadEasy( realpos, normal, size, size,Color( 25, 150, 255 ), self.Angle )
			
		end
		
	end

end