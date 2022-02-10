
ENT.Type = "anim"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.ChainMaterial = Material( "effects/doom_eternal/meathook_chain.png", "noclamp" )
ENT.FireMaterial = Material( "trails/electric.vmt" )
ENT.FireMaterial2 = Material( "effects/fire_cloud1.vmt" )
ENT.BeamMaterial = Material( "effects/dredux/beam/beam_02.png", "smooth" )

function ENT:Initialize( )

	self:SetModel( "models/hunter/misc/sphere025x025.mdl" )
	self:SetPos( self:GetOwner():GetShootPos() )
	self:SetParent( self:GetOwner():GetActiveWeapon() )

	if !IsValid( self:GetOwner():GetActiveWeapon() ) || !isfunction( self:GetOwner():GetActiveWeapon().GetMeathookEnd ) then return end

	self:SetModelScale( 2 )
	self:DrawShadow( false )

	self.MeathookEnd = self:GetOwner():GetActiveWeapon():GetMeathookEnd()

	--self:EmitSound( "doom_eternal/weapons/supershotgun/ssg_meathook_fire.ogg", nil, nil, nil, CHAN_WEAPON )



end

function ENT:Think()

	self:SetPos( self:GetOwner():GetShootPos() )

end

function ENT:OnRemove()

	self:EmitSound( "doom_eternal/weapons/supershotgun/ssg_meathook_detach.ogg", nil, nil, nil, CHAN_WEAPON )
	if SERVER && IsValid( self.MeathookEnd ) then self.MeathookEnd:Remove() return end

end

function ENT:Draw()

	local owner = self:GetOwner()
	local weapon = owner:GetActiveWeapon()

	if !IsValid( owner ) || !IsValid( weapon ) then return end

	if weapon:GetClass() ~= "weapon_dredux_de_supershotgun" then return end

		local mastered = true

		local muzEnt = ((owner != LocalPlayer()) or owner:ShouldDrawLocalPlayer()) && owner:GetActiveWeapon() or owner:GetViewModel()
		local _end = self.MeathookEnd

		if IsValid( _end ) && weapon:GetMeathook() then

			local startpos = muzEnt:GetAttachment( muzEnt:LookupAttachment( "meathook" ) ).Pos
			local endpos = _end:GetPos()

			local dist = ( startpos - endpos ):Length()

			local col = render.GetLightColor( self:GetPos() )
			col.r = col.r * 2
			col.g = col.g * 2
			col.b = col.b * 2

			if mastered then

				render.SetMaterial( self.FireMaterial2 )

				render.DrawBeam( startpos, endpos, 8, 0, 0.5 + math.random()*0.1, Color( 255, 250, 240, 255 ) )

			end

			render.SetMaterial( self.ChainMaterial	)
			render.DrawBeam( endpos, startpos, 4, 0, dist / 25, Color( 255*col.r, 200*col.g, 100*col.b ) )

			if mastered then

				render.SetMaterial( self.FireMaterial )
				for i = 1,2 do render.DrawBeam( endpos, startpos, 14, CurTime()*5, CurTime()*5 + ( dist / ( 250+math.random()*5 ) ), Color( 255, 50, 0 ) ) end
				--render.DrawBeam( endpos, startpos, 16, 0, dist / ( 80+math.random() ), Color( 255*col.r, 25*col.g, 0 ) )

			end

			--render.SetMaterial( self.FireMaterial2 )

			--render.DrawBeam( startpos, endpos, 4, 0, 0.25 + math.random()*0.1, Color( 255, 250, 240, 255 ) )
			--render.DrawBeam( endpos, startpos, 7, 0,  dist / ( 20+math.random() ), Color( 255, 150, 50, 255 ) )

			--[[render.SetMaterial( self.BeamMaterial )
			render.DrawBeam( endpos, startpos, 32, 0, dist / 4000, Color( 100, 200, 255 ) )

			render.SetMaterial( self.FireMaterial )
			render.DrawBeam( endpos, startpos, 8, 0, dist / 80, Color( 75, 100, 255 ) )

			render.DrawBeam( endpos, startpos, 16, 0, dist / 60, Color( 75, 100, 255 ) )]]

		end

end

AddCSLuaFile()
