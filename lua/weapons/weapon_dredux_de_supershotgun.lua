if CLIENT then
   SWEP.PrintName          = "Super Shotgun"
   SWEP.Slot               = 2

end


SWEP.Base = "weapon_dredux_base2"
SWEP.Spawnable = false

SWEP.Primary.Damage = GetConVar("ttt2_doomguy_shotgun_base_dmg"):GetInt() or 5
SWEP.Primary.TakeAmmo = 2
SWEP.Primary.Ammo = "Buckshot"
SWEP.AmmoEnt = "item_box_buckshot_ttt" --The ammo type will it use
SWEP.Primary.DefaultClip = 8
SWEP.Primary.ClipSize = -0
SWEP.Primary.Spread = 2
SWEP.Primary.NumberOfShots = 10
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Force = 0.1
SWEP.HeadshotMultiplier = 1
SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = nil
SWEP.AutoSpawnable = false
SWEP.InLoadoutFor = nil
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = true
SWEP.LimitedStock = true

SWEP.CSMuzzleFlashes = true

if CLIENT then
   -- Path to the icon material
   SWEP.Icon = "VGUI/ttt/dbshotgun"

   -- Text shown in the equip menu
   SWEP.EquipMenuData = {
      type = "Weapon",
      desc = "An extremely powerful but very close range shotgun. Alt Fire grapples you toward a target. Uses shotgun ammo."
   };
end

if SERVER then
   resource.AddFile("materials/VGUI/ttt/dbshotgun.vmt")
end


SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 60
SWEP.ViewModel			= "models/doom_eternal/weapons/supershotgun/supershotgun.mdl"
SWEP.WorldModel			= "models/doom_eternal/weapons/supershotgun/supershotgun_3rd.mdl"
SWEP.UseHands           = false

SWEP.FirstDeploy = true
SWEP.IsEmpty = false

SWEP.Reticle = {}

SWEP.IsDOOMWeapon = false
SWEP.IsDOOMEternalSSG = true
SWEP.VMOffset = Vector( 0, 0, 0 )

SWEP.IsDOOMModdableWeapon = false

SWEP.ChainMaterial = Material( "effects/doom/custom/meathook_chain.png", "vertexlitgeneric noclamp transparent smooth" )
SWEP.NextMeathookSound = CurTime()

SWEP.ViewModelBoneMods = {
	["hooktip_part01_md"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["defaultmod_barrel_md"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["hooktip_hooktipleft_md"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["hooktip_hooktipright_md"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.VElements = {}
SWEP.WElements = {}

function SWEP:Ammo1()
   return IsValid(self:GetOwner()) and self:GetOwner():GetAmmoCount(self.Primary.Ammo) or false
end

-- Hooks functions

hook.Add( "KeyPress", "MeathookRelease", function( ply, key )

	local weapon = ply:GetActiveWeapon()

	if weapon.IsDOOMEternalSSG && weapon:GetMeathook() then

		if key == IN_JUMP && IsFirstTimePredicted() then

			weapon:PlayVMSequence( "meathook_out" )
			weapon:StopMeathook( ply:IsOnGround() )

		end

	end

end)


hook.Add( "SetupMove", "MeathookStrafe", function( ply, mv, cmd )

	local weapon = ply:GetActiveWeapon()

	if weapon.IsDOOMEternalSSG && weapon:GetMeathook() then

		cmd:SetForwardMove( 0 )
		cmd:RemoveKey( IN_FORWARD )
		cmd:RemoveKey( IN_BACK )

		if not ply:IsOnGround() then

			local move = cmd:GetSideMove()
			local move_normal = move == 0 && move || ( move > 0 && 1 || -1 )

			local add = ply:IsOnGround() && Vector() || ( ply:GetRight() * move_normal * ply:GetWalkSpeed()*2 )

			ply:SetVelocity( -ply:GetVelocity() + ply:GetVelocity()*1.25 + add )

		end

	end

end)

-- Weapon functions

function SWEP:OnInitialize()

	self:SetWeaponHoldType( "shotgun" )

	if CLIENT then

		self.Reticle[1] = Material("hud/reticle/ssg_eternal/ret_1.png", "noclamp transparent smooth" )
		self.Reticle[2] = Material("hud/reticle/ssg_eternal/ret_2.png", "noclamp transparent smooth" )
		self.Reticle[3] = Material("hud/reticle/ssg_eternal/ret_3.png", "noclamp transparent smooth" )
		self.Reticle[4] = Material("hud/reticle/ssg_eternal/ret_4.png", "noclamp transparent smooth" )

	end

	self:SetMeathookReady( true )
	self:SetMeathook( false )

	if SERVER then
		util.PrecacheModel( "models/doom_eternal/weapons/supershotgun/chain_segment.mdl" )
		util.PrecacheModel( "models/doom_eternal/weapons/supershotgun/chain_meathook.mdl" )
	end

	self.MeathookDistance = 2000

end

-- Think --

function SWEP:OnThink()

	if self:IsValid() then self:ProcessMeathook() end

	if not ( game.SinglePlayer() && CLIENT ) then

		if ( self:GetMeathookReady() || self:GetMeathook() ) then

			self.HookOffsetY = math.Approach( self.HookOffsetY, 2.5, 0.5 )
			self.HookOffsetX = math.Approach( self.HookOffsetX, 0.4, 0.5 )

		else

			self.HookOffsetY = math.Approach( self.HookOffsetY, 0, 0.5 )
			self.HookOffsetX = math.Approach( self.HookOffsetX, 3, 0.5 )

		end

	end

	if self:GetMeathookReady() then

		local vm = self.Owner:GetViewModel()
		local aim = self.Owner:GetAimVector()
		local pos = self.Owner:GetShootPos()

		local owner = self:GetOwner()

		local trdata = {}
		trdata.start = pos + aim * 40
		trdata.endpos = pos + aim * 1500
		trdata.mins = Vector( -30, -30, -20 )
		trdata.maxs = Vector( 30, 30, 20 )
		trdata.filter = function( ent ) return ent ~= self.Owner && ent:Health() > 0 end
		trdata.ignoreworld = true

		local direction = util.TraceHull( trdata )

		if SERVER && IsValid( direction.Entity ) && ( direction.Entity:IsNPC() || direction.Entity:IsNextBot() || direction.Entity:IsPlayer() ) && self:GetOwner():VisibleVec( direction.Entity:GetPos() + direction.Entity:OBBCenter() )  then

			self:SetMeathookEntity( direction.Entity )

		elseif SERVER then

			self:SetMeathookEntity( NULL )

		end

	end

	if CLIENT then

		if not self:GetMeathookReady() then
			self.ViewModelBoneMods.hooktip_hooktipleft_md.pos.y = Lerp( 0.1, self.ViewModelBoneMods.hooktip_hooktipleft_md.pos.y, 0.35 )
			self.ViewModelBoneMods.hooktip_hooktipright_md.pos.y = Lerp( 0.1, self.ViewModelBoneMods.hooktip_hooktipright_md.pos.y, -0.35 )
		else
			self.ViewModelBoneMods.hooktip_hooktipleft_md.pos.y = Lerp( 0.1, self.ViewModelBoneMods.hooktip_hooktipleft_md.pos.y, 0.75 )
			self.ViewModelBoneMods.hooktip_hooktipright_md.pos.y = Lerp( 0.1, self.ViewModelBoneMods.hooktip_hooktipright_md.pos.y, -0.75 )
		end


		if self:Ammo1() >= self.Primary.TakeAmmo || self:GetMeathook() then
			self.EmptyMul = math.Approach( self.EmptyMul, 0, 0.1 )
		else
			self.EmptyMul = math.Approach( self.EmptyMul, 1, 0.1 )
		end

	end


end

-- Variables --


function SWEP:SetupDataTables()

	self:NetworkVar( "Bool", 0, "MeathookReady" )
	self:NetworkVar( "Bool", 1, "Meathook" )
	self:NetworkVar( "Bool", 2, "MeathookShot" )


	self:NetworkVar( "Entity", 0, "MeathookEntity" )
	self:NetworkVar( "Entity", 1, "MeathookEnd" )

end

-- Deployment --

function SWEP:OnDeploy()

	self:EmitSound( "doom/weapons/switch_weapon.ogg" )

	self:SetNextPrimaryFire( CurTime() + 0.2 )
	self:SetNextSecondaryFire( CurTime() + 0.2 )

	if GetConVar( "dredux_intro" ):GetBool() && self.FirstDeploy and self:Ammo1() > 0 then
		self:EmitSound( "doom_eternal/weapons/supershotgun/ssg_intro.ogg" )
		self:PlayVMSequence( "intro" )
		self.FirstDeploy = false
	else
		self:EmitSound( "doom/weapons/switch_weapon.ogg" )
		self:PlayVMSequence( "bringup" )
	end

	self.CanDisableMeathook = false

	self:SetMeathook( false )
	if IsValid( self.MeathookChain ) then self.MeathookChain:Remove() end
	if IsValid( self:GetMeathookEnd() ) then self:GetMeathookEnd():Remove() end

	if not self:GetMeathookReady() then

		self:SetNextSecondaryFire( CurTime() + 0.5 )

		timer.Simple( 0.5, function()
			if IsValid( self ) then self:SetMeathookReady( true ) end
			self:EmitSound( "doom_eternal/weapons/supershotgun/ssg_meathook_ready.ogg", nil, nil, nil, CHAN_STATIC )
		end )
	end

	--self:StopMeathook()

end

function SWEP:OnHolster()

	if IsValid( self:GetMeathookEnd() ) && SERVER then self:GetMeathookEnd():Remove() end
	self:StopMeathook()

end

-- Primary attack

function SWEP:PrimaryAttack()

	if self:Ammo1() < self.Primary.TakeAmmo then
		self:EmitSound( "doom_eternal/weapons/dryfire.ogg" )
		self:SetNextPrimaryFire( CurTime() + 0.2 )
		--self:PlayVMSequence( "dryfire" )
		return
	end

	self.NextHolster = CurTime() + 0.2

	self.MeathookShot = self:GetMeathook()
	self:StopMeathook( self:GetOwner():IsOnGround() )

	self:TakePrimaryAmmo( self.Primary.TakeAmmo )

	local primary = table.Copy( self.Primary )
	primary.Damage = self:ScaleOutputDamage( self.Primary, "dredux_dmg_supershotgun" )
	self:BulletAttack( primary )

	self:EmitSoundWDelay( "doom_eternal/weapons/supershotgun/ssg_fire_"..math.random(3)..".ogg", 100, math.random( 97, 103 ), nil )
	--self:EmitSound( "doom/weapons/ssg/ssg_fire.ogg", 90, nil, nil, CHAN_WEAPON )

	self.MuzzleEffect = "dredux_muzzleflash_shotgun_eternal_2"
	self:MuzzleFlashEffect( "muzzle_left" )
	self:MuzzleFlashEffect( "muzzle_right" )

	self:ShellEject( "ShotgunShellEject", self.Owner:GetAimVector()*-5 + self.Owner:GetRight()*20 + self.Owner:GetUp()*-40, 0.45 )
	self:ShellEject( "ShotgunShellEject", self.Owner:GetAimVector()*-5 + self.Owner:GetRight()*20 + self.Owner:GetUp()*-40, 0.45 )

	self:PlayVMSequence( "meathook_out" )
	self:PlayVMSequence( "shoot" )

	self:PlayVMSequenceWDelay( "shoot_reload", self:VMSequenceDuration()-0.05 )

	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self:GetOwner():SetVelocity( self:GetOwner():GetAimVector() * -100 )
	self.Owner:ViewPunch( Angle( -8, 0, 0 ) )

	self:SetNextPrimaryFire( CurTime() + 1.5 )
	self:SetNextSecondaryFire( CurTime() + 1.5 )

end

function SWEP:CustomBulletCallback( attacker, tr, dmg )

	local prop = util.GetSurfacePropName( tr.SurfaceProps )

	if not tr.Entity:IsPlayer() then
		--dmg:SetDamageType( bit.bor( dmg:GetDamageType(), DMG_BLAST ) )
		--timer.Simple( 0, function() if IsValid( tr.Entity ) then tr.Entity:Extinguish() end end )
	end

	return true
end

-- Meathook

function SWEP:SecondaryAttack()

	if ( not self:GetMeathookReady() or self:GetMeathook() or not IsFirstTimePredicted() ) then return end

	self:SetNW2Bool( "IsMastered", DModRedux:GetWeaponMod( self:GetOwner(), "DESSG_Fire" ) )

	self:BeginMeathook()

	self:SetNextSecondaryFire( CurTime() + 0.1 )

end

function SWEP:BeginMeathook()

	local ent = self:GetMeathookEntity()

	if not IsValid( ent ) or self:GetMeathook() then return end

	local aim = self.Owner:GetAimVector()
	local pos = self.Owner:GetShootPos()

	local trdata2 = {}
	trdata2.start = pos + aim * 40
	trdata2.endpos = ent:GetPos() + ent:OBBCenter()
	trdata2.filter = { self.Owner }

	local direction2 = util.TraceLine( trdata2 )
	local direction_normal = ( direction2.HitPos - pos ):GetNormalized()
	local dist = 1500 * direction2.Fraction

	debugoverlay.Cross( direction2.HitPos, 25, 25, 10 )

	if ( not direction2.Hit ) then return end

	if ( direction2.Entity:IsNPC() or direction2.Entity:IsNextBot() or direction2.Entity:IsPlayer() ) then

		if SERVER then

			self:EmitSoundWDelay( "doom_eternal/weapons/supershotgun/ssg_meathook_fire.ogg", nil, nil, nil, CHAN_AUTO, 0 )
			--self:EmitSoundWDelay( "doom_eternal/weapons/supershotgun/ssg_meathook_fire_mastered.ogg", nil, nil, nil, CHAN_AUTO, 0 )

			self:SetMeathookReady( false )
			self:SetMeathook( true )

			-- Owner physics

			local owner = self:GetOwner()

			owner:SetVelocity( -owner:GetVelocity() + owner:GetUp()*25 + direction_normal * 50 )
			--owner:SetVelocity( Vector( 0, 0, -owner:GetVelocity().z ) )

			self.MeathookDistance = pos:DistToSqr( ent:GetPos() )
			self.MeathookDistance2 = pos:DistToSqr( ent:GetPos() )

			-- Hook entity

			local hook = ents.Create( "prop_dynamic" )
			hook:SetModel( "models/doom_eternal/weapons/supershotgun/chain_meathook.mdl" )
			hook:SetModelScale( 1 )
			hook:SetPos( direction2.HitPos )
			hook:SetParent( direction2.Entity )
			hook:SetAngles( direction_normal:Angle() )

			self.Chain = ents.Create( "ent_dmod_meathook" )
			self.Chain:SetOwner( self:GetOwner() )
			self.Chain:Activate()
			self.Chain:Spawn()
			self:DeleteOnRemove( self.Chain )

			self:PlayVMSequence( "meathook_into" )

			self:DeleteOnRemove( hook )
			self:SetMeathookEnd( hook )

			self.CanDisableMeathook = false
			timer.Simple( 0.25, function() if IsValid( self ) then self.CanDisableMeathook = true end end )

			local ent = direction2.Entity
			if ( not ent.StunImmune && ent:GetMaxHealth() < 2500*GetConVar( "dredux_dmg_mul" ):GetFloat() ) then

				if ent:IsNPC() then
					ent:NextThink( CurTime() + 0 )
					if SERVER then ent:StopMoving() end
				elseif ent.IsDrGNextbot then
					ent:NextThink( CurTime() + 0 )
				end

			end

		end
		--return constraint.Rope( owner, hook, 0, 0, Vector(), Vector(), dist, 100, 0, 0, "trails/smoke", false )

	end

end

function SWEP:ProcessMeathook()

	local owner = self:GetOwner()
	local ent = self:GetMeathookEntity()
	local meathook = self:GetMeathookEnd()

	if not self:GetMeathook() or not ent then return end

	if  SERVER and self.CanDisableMeathook && IsValid( ent ) then

		local selfpos = self:GetOwner():GetPos()
		local target = ent:NearestPoint( selfpos )

		if ( not IsValid( ent ) or not IsValid( meathook ) or not self:IsInCone( ent, owner:GetFOV() - 5 ) or not self:GetOwner():VisibleVec( meathook:GetPos() ) or selfpos:DistToSqr( target ) < 25^2 or selfpos:DistToSqr( target ) > self.MeathookDistance + 75^2 ) or self:GetOwner():GetVelocity():Length() > 1500 then

			self:PlayVMSequence( "meathook_out" )
			self:StopMeathook( owner:IsOnGround() )

		end

		self.MeathookDistance = selfpos:DistToSqr( target )

	elseif not IsValid( ent ) then

		self:PlayVMSequence( "meathook_out" )
		self:StopMeathook( owner:IsOnGround() )

	end

	if IsValid( meathook ) and IsValid( ent ) then

		local owner = self:GetOwner()

		local pos = meathook:GetPos()
		local direction_normal = ( pos - owner:GetPos() ):GetNormalized()

		if SERVER then ent:Ignite( ent:IsPlayer() and 0 or 0.5 ) end

		if owner:IsOnGround() then

			local Velocity = owner:GetVelocity()
			owner:SetVelocity( -Velocity )
			owner:SetVelocity( direction_normal * 80 + owner:GetUp() * 25 )

			owner:SetPos( owner:GetPos() + owner:GetUp()*2 )

		else

			local Velocity = owner:GetVelocity()
			owner:SetVelocity( -Velocity )
			owner:SetVelocity( direction_normal * 14 + owner:GetUp() * 7.5 )

		end

		if game.SinglePlayer() or CLIENT then

			local current = owner:EyeAngles()
			local target = ( self:GetMeathookEnd():GetPos() - owner:GetShootPos() ):Angle()
			target.pitch = Lerp( 0.1, current.pitch, target.pitch )
			local result = LerpAngle( 0.15, current, target )

			owner:SetEyeAngles( Angle( current.pitch, result.yaw, 0 ) )

		end

	end

	if IsValid( meathook ) and self.NextMeathookSound < CurTime() and IsFirstTimePredicted() then
		self:EmitSound( "doom_eternal/weapons/supershotgun/ssg_meathook_loop.ogg", nil, nil, nil, CHAN_WEAPON )
		self.NextMeathookSound = CurTime() + 1.2
	end

end

function SWEP:StopMeathook( IsOnGround )

	if IsValid( self ) and self:GetMeathook() and IsFirstTimePredicted() then

		self:SetMeathook( false )

		if IsValid( self.MeathookChain ) then self.MeathookChain:Remove() end
		if IsValid( self.Chain ) then self.Chain:Remove() end

		timer.Simple( 0, function()

			if IsValid( self ) and IsValid( self:GetOwner() ) then

				local owner = self:GetOwner()

				local vel = owner:GetVelocity()
				local upvel = IsOnGround and 100 or 400

				owner:SetVelocity( -owner:GetVelocity()*0.25 + owner:GetUp()*upvel + vel:GetNormalized() * 100 )

			end

		end )

		timer.Simple( 3, function() if self:IsValid() then self:EmitSound( "doom_eternal/weapons/supershotgun/ssg_meathook_ready.ogg", nil, nil, nil, CHAN_STATIC ) self:SetMeathookReady( true ) end end)

		self:StopSound( "doom_eternal/weapons/supershotgun/ssg_meathook_loop.ogg" )
		self:EmitSoundWDelay( "doom_eternal/weapons/supershotgun/ssg_meathook_detach.ogg", 90, nil, nil, CHAN_WEAPON, 0 )

		if SERVER then
			if IsValid( self:GetMeathookEnd() ) then self:GetMeathookEnd():Remove() end
		end

	end

end

-- Bone scaler

function SWEP:SetVMeathHook( set )

	--local vm = self:GetOwner():GetViewModel()
	--vm:ManipulateBoneScale( vm:LookupBone( "hooktip_part01_md" ), set )
	--vm:ManipulateBoneScale( vm:LookupBone( "hooktip_hooktipleft_md" ), set )
	--vm:ManipulateBoneScale( vm:LookupBone( "hooktip_hooktipright_md" ), set )

end

SWEP.CenteredPos = Vector( 0, 0, 0 )
SWEP.CenteredAng = Vector( 0, 0, 0 )

SWEP.EmptyPos  = Vector( 1.5, -4, 0.55)
SWEP.EmptyAng  = Vector( -5, 15, -5 )

SWEP.EmptyMul = 0
SWEP.OffsetMul = 1

function SWEP:GetViewModelPosition(EyePos, EyeAng)

	local OffsetPos = Vector()
	local OffsetAng = Vector()

	if not IsValid( self ) then return end

	if self:Ammo1() ~= false then

		self.ViewModelBoneMods.defaultmod_barrel_md.angle = Angle( 0, 0, 0 )
		self.ViewModelBoneMods.hooktip_part01_md.angle = Angle( 0, 0, 0 )

	else

		self.ViewModelBoneMods.defaultmod_barrel_md.angle = Angle( 10, 0, 0 )
		self.ViewModelBoneMods.hooktip_part01_md.angle = Angle( 12, 0, 0 )

	end

	local EmptyAng = self.EmptyAng

    EyeAng = EyeAng * 1

	EyeAng:RotateAroundAxis( EyeAng:Right(), EmptyAng.x * self.EmptyMul )
	EyeAng:RotateAroundAxis( EyeAng:Up(), EmptyAng.y * self.EmptyMul )
	EyeAng:RotateAroundAxis( EyeAng:Forward(), EmptyAng.z * self.EmptyMul )

	EyeAng:RotateAroundAxis( EyeAng:Right(), OffsetAng.x * self.OffsetMul )
	EyeAng:RotateAroundAxis( EyeAng:Up(), OffsetAng.y * self.OffsetMul )
	EyeAng:RotateAroundAxis( EyeAng:Forward(), OffsetAng.z * self.OffsetMul )

	local Right 	= EyeAng:Right()
	local Up 		= EyeAng:Up()
	local Forward 	= EyeAng:Forward()

	local EmptyPos = self.EmptyPos

	EyePos = EyePos + EmptyPos.x * Right * self.EmptyMul
	EyePos = EyePos + EmptyPos.y * Forward * self.EmptyMul
	EyePos = EyePos + EmptyPos.z * Up * self.EmptyMul

	return EyePos, EyeAng

end

-- Crosshair

SWEP.HookOffsetX = 0.4
SWEP.HookOffsetY = 4

if CLIENT then

SWEP.HookDefault = Vector( ScrW()/2, ScrH()/2 + ScrW()*0.01*2.75 )
SWEP.HookCurrent = SWEP.HookDefault

end


function SWEP:DrawHUD( x, y )

	if self:GetMeathookReady() then

		self:DrawCrosshairElementRotated( 1, 6.5, 0, -3.25, 0, 170, 200, 50, 255 )
		self:DrawCrosshairElementRotated( 1, 6.5, 180, 3.25, 0, 170, 200, 50, 255 )

		if IsValid( self:GetMeathookEntity() ) then

			local ent = self:GetMeathookEntity()

			local pos2D = ( ent:GetPos() + ent:OBBCenter() ):ToScreen()

			if pos2D.visible then

				surface.SetMaterial( self.Reticle[4] )
				surface.SetDrawColor( 255, 255, 255, 200 )

				local w = ScrW()
				local h = ScrH()
				local aspect_ratio = ( h / w )

				local pos_x = math.Clamp( pos2D.x, w*0.5 - w*0.2*aspect_ratio, w*0.5 + w*0.2*aspect_ratio )
				local pos_y = math.Clamp( pos2D.y, h*0.5 - h*0.2, h*0.5 + h*0.2 )

				self.HookCurrent = Vector( math.Approach( self.HookCurrent.x, pos_x, FrameTime() * 1024 * aspect_ratio ), math.Approach( self.HookCurrent.y, pos_y, FrameTime() * 1024 ), 0 )

				local size = 1.75
				local mul = w*0.01

				surface.SetDrawColor( 170, 200, 50, 255 )

				surface.SetMaterial( self.Reticle[3] )
				surface.DrawTexturedRectRotated( self.HookCurrent.x + mul * -0.4, self.HookCurrent.y, w*size*0.01, w*size*0.01, 0 )

				surface.SetMaterial( self.Reticle[4] )
				surface.DrawTexturedRectRotated( self.HookCurrent.x + mul * 0.4, self.HookCurrent.y, w*size*0.01, w*size*0.01, 0 )

			end

		else

			self.HookCurrent = self.HookDefault

			self:DrawCrosshairElementRotated( 3, 1.75, 0, -0.375, 3.5, 170, 200, 50, 255 )
			self:DrawCrosshairElementRotated( 4, 1.75, 0, 0.375, 3.5, 170, 200, 50, 255 )

		end

	elseif not self:GetMeathookReady() then


		self:DrawCrosshairElementRotated( 1, 6.5, 0, -3.25, 0, 255, 0, 0, 255 )
		self:DrawCrosshairElementRotated( 1, 6.5, 180, 3.25, 0, 255, 0, 0, 255 )

		self:DrawCrosshairElementRotated( 3, 1.75, 0, -2.75, 0,  255, 0, 0, 255 )
		self:DrawCrosshairElementRotated( 4, 1.75, 0, 2.75, 0,  255, 0, 0, 255 )

	end


	return true

end
