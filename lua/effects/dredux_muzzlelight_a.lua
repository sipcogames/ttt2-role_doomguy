EFFECT.Time = 0

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	

	self.RealPos = self:GetTracerShootPos( self.Pos, self.Weapon, self.Att ) + self.Weapon:GetOwner():EyeAngles():Up() * 15 + self.Weapon:GetOwner():EyeAngles():Right() * -15
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )
	
	local muzzlelight = DynamicLight( self.Weapon:GetOwner():GetViewModel():EntIndex(), false )
	muzzlelight.Pos = self.RealPos
	muzzlelight.Size = 256
	muzzlelight.Decay = 4096
	muzzlelight.R = 50
	muzzlelight.G = 125
	muzzlelight.B = 255
	muzzlelight.Brightness = 2
	muzzlelight.DieTime = CurTime()+0.05
	
end

function EFFECT:Think()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end 

	self.Time = self.Time + FrameTime()
	return self.Time < 0.01
	
end


function EFFECT:Render()

	return true
	
end