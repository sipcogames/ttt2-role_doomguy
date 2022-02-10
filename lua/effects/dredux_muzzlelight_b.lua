EFFECT.Time = 0

function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	self.Weapon = data:GetEntity()
	self.Att = data:GetAttachment()	

	if !IsValid( self.Weapon ) then return end

	self.RealPos = self:GetTracerShootPos( self.Pos, self.Weapon, self.Att ) + self.Weapon:GetOwner():EyeAngles():Up() * 15 + self.Weapon:GetOwner():EyeAngles():Right() * -10
	self.IsViewModelEffect = !( ( self.Weapon:GetOwner() != LocalPlayer() ) or self.Weapon:GetOwner():ShouldDrawLocalPlayer() )
	
	self.MuzzleLight = DynamicLight(  self.Weapon:GetOwner():GetViewModel():EntIndex(), false )
	self.MuzzleLight.Pos = self.RealPos
	self.MuzzleLight.Size = 256
	self.MuzzleLight.Decay = 4000
	self.MuzzleLight.R = 255
	self.MuzzleLight.G = 150
	self.MuzzleLight.B = 50
	self.MuzzleLight.Brightness = 2
	self.MuzzleLight.DieTime = CurTime()+0.05
	
end

function EFFECT:Think()

	if !IsValid( self.Weapon ) || !IsValid( self.Weapon:GetOwner() ) then return end 

	self.MuzzleLight.Pos = self.RealPos

	self.Time = self.Time + FrameTime()
	return self.Time < 0.01
	
end


function EFFECT:Render()

	return true
	
end