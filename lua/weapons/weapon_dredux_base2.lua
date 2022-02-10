-- Based on SCK Base Code, god save the creator of that one

SWEP.Base = "weapon_base"

SWEP.Author = "Rex"
SWEP.Contact = ""
SWEP.Purpose = "Rip and Tear!"
SWEP.Instructions = "Aim and pull the trigger. R to change weapon mods. RMB to use them."
SWEP.Category = "DOOM"

SWEP.Primary.ClipSize = -1

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"

SWEP.BobScale = 0
SWEP.SwayScale = 0

SWEP.IDWeapon = true

SWEP.NextHolster = CurTime()

----------------------------------------------------------------------------------------------------

if SERVER then

	util.AddNetworkString( "DOOM_MeleeAttack" )
	
end

--

----------------------------------------------------------------------------------------------------

hook.Add( "SetupMove", "DOOMWeapon_SetupMove", function( ply, mv, cmd )

	local wep = ply:GetActiveWeapon()
	
	if IsValid( wep ) && ( wep.IDWeapon  && wep:GetActiveMod() || ( wep:GetClass() == "weapon_dredux_de_chaingun" && wep:GetActiveShield() ) ) then
	
		if ( wep:GetClass() == "weapon_dredux_d2016_gauss" || wep:GetClass() == "weapon_dredux_de_gauss" ) && wep:GetSelectedMod() == 2 then
		
			mv:SetMaxClientSpeed( 1 )
			cmd:SetForwardMove( 1 )
			cmd:SetSideMove( 1 )
			
		else
			
			mv:SetMaxClientSpeed( mv:GetMaxClientSpeed() * 0.5 )
			cmd:SetForwardMove( cmd:GetForwardMove() * 0.5 )
			cmd:SetSideMove( cmd:GetSideMove() * 0.5 )
			
		end
	
	end

end)

hook.Add( "StartCommand", "DOOMWeapon_NoJump", function( ply, cmd )

	local wep = ply:GetActiveWeapon()
	
	if IsValid( wep ) and ( wep.IDWeapon  and wep:GetActiveMod() or ( wep:GetClass() == "weapon_dredux_de_chaingun" and wep.GetActiveShield and wep:GetActiveShield() ) ) and not ply:IsOnGround() then
		cmd:RemoveKey( IN_JUMP )
	end

end)

----------------------------------------------------------------------------------------------------

function SWEP:Initialize( Restored )

	-- other initialize code goes here
	
	if not Restored then self.FirstDeploy = true end
	self.IsPlayingIntroAnimation = true
	
	self.MuzzleEffect = "dredux_muzzleflash"
	self.NextReload = CurTime()
	self.NextHolster = CurTime()
	
	self:OnInitialize()

	if CLIENT then
	
		-- Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) -- create viewmodels
		self:CreateModels(self.WElements) -- create worldmodels
		
		-- init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				-- Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					-- we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					-- ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					-- however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
		if IsValid( self:GetOwner() ) then
			self.DefaultFOV = self:GetOwner():GetFOV()
		end
		
	end

end

function SWEP:OnRestore()

	--self:Initialize( true )
	
	if SERVER then
		self:Deploy()
		self:CallOnClient( "Deploy" )
	end

end

----------------------------------------------------------------------------------------------------

function SWEP:Think()

	self:OnThink()
	self:CallOnClient( "OnClientThink" )
	
	return
	
end

----------------------------------------------------------------------------------------------------

function SWEP:Deploy( InstantDeploy )

	self:SetNWBool( "ActiveWeapon", true )
	self:SetActiveMod( false )
	
	if not InstantDeploy then self.NextHolster = CurTime() + 0.1 self:OnDeploy() end
	
	self.FirstDeploy = false
	self:CallOnClient( "GetDefaultFOV" )
	
	return true
	
end

function SWEP:GetDefaultFOV()
	if IsValid( self:GetOwner() ) then
		self.DefaultFOV = self:GetOwner():GetFOV()
	end
end

----------------------------------------------------------------------------------------------------

function SWEP:Holster( ent )
	
	if self.NextHolster >= CurTime() then 
	
		timer.Simple( math.Clamp( self.NextHolster - CurTime(), 0.025, 1 ), function()
		
			if IsValid( self ) && IsValid( self:GetOwner() ) then
			
				self:SetNWBool( "ActiveWeapon", false )
				self:SetActiveMod( false )
			
				if CLIENT and IsValid(self.Owner) then
					local vm = self.Owner:GetViewModel()
					if IsValid(vm) then
						self:ResetBonePositions(vm)
						vm:StopParticles()
					end
				end
				
				self:OnHolster()
				
				if SERVER then
			
					if IsValid( self:GetOwner() ) then self:GetOwner():SetFOV( 0, 0 ) end
					if IsValid( ent ) then self:GetOwner():SelectWeapon( ent:GetClass() ) end
					
				end
				
			end
			
		end )
		
		return false
		
	else
	
		if CLIENT and IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				vm:StopParticles()
			end
		end
	
		self:SetNWBool( "ActiveWeapon", false )
		self:SetActiveMod( false )
		
		self:OnHolster()
		
		return true
		
	end
	
	return true
	
end

----------------------------------------------------------------------------------------------------

function SWEP:OnRemove()
	self:Holster()
end

function SWEP:PostHolster()
end

----------------------------------------------------------------------------------------------------

function SWEP:MuzzleFlashEffect( att )

	if not IsFirstTimePredicted() then return end
	
	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetOrigin( self.Owner:GetShootPos() )
	att = att and self:LookupAttachment( att ) or 1
	fx:SetAttachment( att )
	util.Effect( self.MuzzleEffect, fx )
	
end

function SWEP:ShellEject( shell, offsetpos, delay )

	if not IsFirstTimePredicted() then return end
	if not game.SinglePlayer() and SERVER then return end

	delay = delay or 0

	timer.Simple( delay, function()

		if IsValid( self ) and IsValid( self:GetOwner() ) and self:GetNWBool( "ActiveWeapon", false ) then

			local data = EffectData()
			data:SetOrigin( self.Owner:GetShootPos() + offsetpos )
			data:SetAngles( ( self.Owner:GetAimVector() + self.Owner:GetRight()*5 + self.Owner:GetUp()*7.5 ):Angle() )
			data:SetEntity( self )
			util.Effect( shell, data )
			
		end
		
	end)

end

----------------------------------------------------------------------------------------------------

function SWEP:UpdateWMBodygroup()
	--if SERVER then
	--	self:CallOnClient( "UpdateWMBodygroup" )
	--end
	self:SetBodygroup( 0, self:GetSelectedMod() )
end

----------------------------------------------------------------------------------------------------

function SWEP:GetSelectedMod()
	return 0
end

function SWEP:GetActiveMod()
	return false
end

function SWEP:SetActiveMod()
	return false
end

----------------------------------------------------------------------------------------------------

SWEP.MeleeAnim = "range_melee_shove"

function SWEP:MeleeAttack()

	local owner = self:GetOwner()

	self:CallOnClient( "PlayMeleeGesture" )
	self:PlayVMSequence( "melee_1" )

	self:EmitSound( "doom/weapons/Melee Swing "..math.random( 3 )..".ogg" )
	owner:ViewPunch( Angle( -5, math.random( 5, 4 ), 0 ) )
	
	local att = {}
	att.NumberOfShots = 1
	
	if SERVER then
		local dmg = self:ScaleOutputDamage( att, "dredux_dmg_melee" )
		local hitent = owner:TraceHullAttack( owner:GetShootPos(), owner:GetShootPos() + owner:GetAimVector() * 80, Vector( -10, -10, -10 ), Vector( 10, 10, 10 ), dmg + math.random( 0, 5 ), DMG_CLUB, 2, false )
		
		if IsValid( hitent ) then
			self:EmitSound( "doom/weapons/Melee Hit Wall "..math.random( 2 )..".ogg" )
		end
		
	end
	
	debugoverlay.Cross( owner:GetShootPos() + owner:GetAimVector() * 50, 25, 1 )
	
	self:OnMeleeAttack()
	self:SetNextPrimaryFire( CurTime() + 0.5 )

end

function SWEP:OnMeleeAttack() return end

function SWEP:PlayMeleeGesture()
	self:GetOwner():AnimRestartGesture( 1, ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND, true )
end

----------------------------------------------------------------------------------------------------

function SWEP:GetTableValue( tbl )
	if not tbl then return end
	return tbl[math.random( #tbl ) ]
end

----------------------------------------------------------------------------------------------------

function SWEP:IsInCone(ent, angle )
	local selfpos = self:GetOwner():GetShootPos()
	local forward = self:GetOwner():GetAimVector()
	return (selfpos + forward):dfunc_Degrees(ent:GetPos(), selfpos) <= angle/2
end

----------------------------------------------------------------------------------------------------

local vecMETA = FindMetaTable("Vector")

function vecMETA:dfunc_Degrees( vec2, origin )
	local vec1 = self
	origin = origin or Vector(0, 0, 0)
	vec1 = vec1 - origin
	vec2 = vec2 - origin
	return math.deg(math.acos(math.Round(vec1:GetNormalized():Dot(vec2:GetNormalized()), 2)))
end

----------------------------------------------------------------------------------------------------

function SWEP:ScaleOutputDamage( tbl, convar )

	if CLIENT then return 0 end
	local num = tbl.NumberOfShots or 1
	return ( GetConVar( convar ):GetInt()*GetConVar( "dredux_dmg_mul" ):GetInt() ) / num 
	
end

----------------------------------------------------------------------------------------------------

function SWEP:CanPrimaryAttack()
	return ( self:Ammo1() >= self.Primary.TakeAmmo && self:GetOwner():WaterLevel() < 3 )
end

----------------------------------------------------------------------------------------------------
-- Animations
----------------------------------------------------------------------------------------------------

function SWEP:PlayVMSequence( seq, restrict )
	if not self:GetNWBool( "ActiveWeapon" ) then return end
	local vm = self.Owner:GetViewModel( )
	vm:SendViewModelMatchingSequence( vm:LookupSequence( seq ) )
end

function SWEP:PlayVMSequenceWDelay( seq, delay )
	local delay = delay or 0
	timer.Simple( delay, function()
		if IsValid( self ) then
			self:PlayVMSequence( seq )
		end
	end)
end

function SWEP:VMSequenceDuration( seq )
	if not IsValid( self ) then return 0 end 
	local vm = self.Owner:GetViewModel( )
	local seq = seq or self:GetSequence()
	return vm:SequenceDuration( vm:LookupSequence( seq ) )
end

----------------------------------------------------------------------------------------------------
-- Sounds
----------------------------------------------------------------------------------------------------

function SWEP:EmitSoundWDelay( soundName, soundLevel, pitchPercent, volume, channel, delay, IsIntroSound )
	local delay = delay or 0
	timer.Simple( delay, function()
		if ( IsIntroSound and not self.IsPlayingIntroAnimation ) then return end
		if IsValid( self ) and self:GetNWBool( "ActiveWeapon", false ) and IsFirstTimePredicted() then
			self:EmitSound(soundName, soundLevel, pitchPercent, volume, channel )
		end
	end)
end

----------------------------------------------------------------------------------------------------
-- Attack functions
----------------------------------------------------------------------------------------------------

-- Bullet Attack

function SWEP:BulletAttack( tbl, func )

	if not self:GetNWBool( "ActiveWeapon", false ) then return end

	local tbl = tbl or self.Primary
	
	local bullet = {} 
	bullet.Num = tbl.NumberOfShots 
	bullet.Src = self.Owner:GetShootPos() 
	bullet.Dir = self.Owner:GetAimVector() 
	bullet.Spread = Vector( tbl.Spread*0.1 , tbl.Spread*0.1, 0) 
	bullet.Tracer = 1
	bullet.TracerName = tbl.TracerName or "tracer"
	bullet.Force = tbl.Force 
	bullet.Damage = tbl.Damage 
	bullet.AmmoType = tbl.Ammo
	
	bullet.Callback = function( attacker, tr, dmg ) self:CustomBulletCallback( attacker, tr, dmg ) end

	self:GetOwner():FireBullets( bullet ) 
	
end

function SWEP:CustomBulletCallback( attacker, tr, dmg )

	return true

end

-- Projectile Attack

function SWEP:ProjectileAttack( proj, att, vel, spread )
	
	if not self:GetNWBool( "ActiveWeapon", false ) or CLIENT then return end
	
	local proj = proj or "rpg_missile"
	
	local vm = self.Owner:GetViewModel()
	local aim = self.Owner:GetAimVector()
	local pos = self.Owner:GetShootPos()
	
	local spread = math.ceil( spread || 0 )

	local trdata = {}
	trdata.start = pos
	trdata.endpos = pos + aim * 10000
	trdata.filter = self.Owner --function( ent ) return ent ~= self.Owner && ent:Owner() ~= self.Owner end
	trdata.collisiongroup = COLLISION_GROUP_PROJECTILE

	local targ = util.TraceLine( trdata )
	if not targ.Hit then 
		vel = aim:GetNormalized() * vel 
	else
		vel = ( targ.HitPos - att ):GetNormalized() * vel
	end

	local cur_proj = ents.Create( proj )
	cur_proj:SetPos( att )
	cur_proj:SetAngles( vel:Angle() )
	cur_proj:SetOwner( self:GetOwner() )
	
	cur_proj:Spawn()
	
	local phys = cur_proj:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetVelocity( vel + VectorRand()*math.random( spread ) )
	end
	
	return cur_proj
	
end

function SWEP:DealDamage( ent, value, type )

    if ent == self then return end
    local dmg = DamageInfo()
    dmg:SetDamage(value)
    dmg:SetDamageForce(self:GetVelocity())
    dmg:SetDamageType(type or DMG_DIRECT)
    if IsValid(self:GetOwner()) then
      dmg:SetAttacker(self:GetOwner())
    else dmg:SetAttacker(self) end
    dmg:SetInflictor(self)
	dmg:SetDamagePosition( ent:GetPos() + ent:OBBCenter() )
    ent:TakeDamageInfo(dmg)
	
end
  
function SWEP:RadiusDamage( pos, damage, type, range, filter, mindmg )

    local owner = self:GetOwner()
    if not isfunction(filter) then filter = function(ent)
	if ent == owner then return false end
	if not IsValid(owner) or not owner.IsDrGNextbot then return true end
	return not owner:IsAlly(ent)
    end end
	
	local mindmg = mindmg or 0
	
    for i, ent in ipairs(ents.FindInSphere( pos, range)) do
    if not IsValid(ent) then continue end
    if ent == self then continue end
    if not filter(ent) then continue end
		self:DealDamage(ent, damage*math.Clamp((range-self:GetPos():Distance(ent:GetPos()))/range, mindmg, 1), type)
    end
	
end

----------------------------------------------------------------------------------------------------
-- HUD drawing functions
----------------------------------------------------------------------------------------------------

function SWEP:CrosshairScreenPos( x, y )

	local w = ScrW()
	local h = ScrH()
	local pos = {}
	
	pos.x = w*0.5 + w*x*0.01*GetConVar( "cl_dredux_crosshairscale" ):GetFloat()
	pos.y = h*0.5 + w*y*0.01*GetConVar( "cl_dredux_crosshairscale" ):GetFloat()
	
	return pos
	
end

function SWEP:CrosshairScreenScale( x, y )

	local w = ScrW()
	local h = ScrH()
	local size = {}

	size.x = w*x*0.01*GetConVar( "cl_dredux_crosshairscale" ):GetFloat()
	size.y = w*y*0.01*GetConVar( "cl_dredux_crosshairscale" ):GetFloat()
	
	return size
	
end

function SWEP:DrawCrosshairElementRotated( index, size, ang, x, y, r, g, b, a, flipx )

	surface.SetMaterial( self.Reticle[index] )
	surface.SetDrawColor( r or 255, g or 255, b or 255, a or 200 )
	local w = ScrW()
	local h = ScrH()
	
	local pos = self:CrosshairScreenPos( x, y )
	local size = self:CrosshairScreenScale( size, size )
	
	surface.DrawTexturedRectRotated( pos.x, pos.y, size.x, size.y , ang )

end

function SWEP:DrawCrosshairElementWH( index, sizeX, sizeY, ang, x, y, r, g, b, a )

	surface.SetMaterial( self.Reticle[index] )
	surface.SetDrawColor( r or 255, g or 255, b or 255, a or 200 )
	local w = ScrW()
	local h = ScrH()
	
	local pos = self:CrosshairScreenPos( x, y )
	local size = self:CrosshairScreenScale( sizeX, sizeY )
	
	surface.DrawTexturedRectRotated( pos.x, pos.y, size.x, size.y , ang )

end

function SWEP:DrawScreenOverlay( index, size, r, g, b, a )

	surface.SetMaterial( self.Reticle[index] )
	surface.SetDrawColor( r or 255, g or 255, b or 255, a or 200 )
	local w = ScrW()
	local h = ScrH()
	
	surface.DrawTexturedRectRotated( w*0.5, h*0.5, h*4, h, 0 )

end

function SWEP:DrawDelay( index, size, r, g, b, a )

	surface.SetMaterial( self.Delay[index] )
	surface.SetDrawColor( r or 255, g or 255, b or 255, a or 200 )
	local w = ScrW()
	local h = ScrH()
	--local size = self:CrosshairScreenScale( size, size )
	surface.DrawTexturedRectRotated( w*0.5, h*0.5, w*size, w*size, 0 )

end


function SWEP:DrawHUD3DSprite( index, size, pos, r, g, b, a, flipx )

	render.SetMaterial( self.Reticle[index] )
	render.DrawSprite( pos, size, size, 0, Color( r, g, b, a ) )

end

----------------------------------------------------------------------------------------------------

function SWEP:AdjustMouseSensitivity()
	if not self.DefaultFOV then return end
	local val = self:GetActiveMod() && 0.2 or 0
	return self:GetOwner():GetFOV()/self.DefaultFOV - val
end

----------------------------------------------------------------------------------------------------

function SWEP:OnInitialize() return end
function SWEP:OnClientThink() return end
function SWEP:OnThink() return end
function SWEP:OnDeploy() return end
function SWEP:OnHolster() return true end

----------------------------------------------------------------------------------------------------

function SWEP:CalcViewModelView( ViewModel, OldEyePos, OldEyeAng, EyePos, EyeAng )

	if not IsValid( self:GetOwner() ) or not self:GetOwner():Alive() then return end

	if not GetConVar( "cl_dredux_bob" ):GetBool() then
		self.BobScale = 0.5
		self.SwayScale = 0.5
		return
	else
		self.BobScale = 0
		self.SwayScale = 0
	end

	local ply = self:GetOwner()
	local EyePos = OldEyePos
	local EyeAng = OldEyeAng

	local realspeed = ply:GetVelocity():Length2D()/ply:GetRunSpeed()
	local speed = math.Clamp( ply:GetVelocity():Length2DSqr()/ply:GetRunSpeed(), 0.25, 1 )


	-- Viewmodel bobbing

	local in_scope = self:GetActiveMod()

	local bob_x_val = CurTime()*8
	local bob_y_val = CurTime()*16
	
	-- Idle bobbing
	
	local bob_x = math.sin( bob_x_val*0.15 )*0.1
	local bob_y = math.sin( bob_y_val*0.15 )*0.05
	EyePos = EyePos + EyeAng:Right()*bob_x
	EyePos = EyePos + EyeAng:Up()*bob_y	
	EyeAng:RotateAroundAxis( EyeAng:Forward(), 5*bob_x )
	
	if not in_scope then
	
		if realspeed > 0.1 then
		
			-- Walk bobbing
		
			local bobspeed = math.Clamp( realspeed, 0, 1 )
		
			local bob_x = math.sin( bob_x_val*0.8*speed )*0.2*bobspeed
			local bob_y = math.cos( bob_y_val*0.8*speed )*0.1*bobspeed
			EyePos = EyePos + EyeAng:Right()*bob_x*1
			EyePos = EyePos + EyeAng:Up()*bob_y*1
			
		end
		
		-- Sway
		
		--if FrameTime() < 1/15 then
		
			if not self.SwayPos then self.SwayPos = Vector() end
			
			local vel = ply:GetVelocity()
			vel.x = math.Clamp( vel.x/1000, -0.5, 0.5 )
			vel.y = math.Clamp( vel.y/1000, -0.5, 0.5 )
			vel.z = math.Clamp( vel.z/750, -1, 0.25 )
			
			self.SwayPos = LerpVector( FrameTime()*25, self.SwayPos, -vel )
			EyePos = EyePos + self.SwayPos
			
		--end
	
	end
	
	--
	
	local EyePos, EyeAng = self:GetViewModelPosition( EyePos, EyeAng )
	return EyePos, EyeAng
	
end

function SWEP:DoDrawCrosshair()
	return true
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	
	-- Set us up the texture
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetTexture( self.WepSelectIcon )
	
	-- Lets get a sin wave to make it bounce
	local fsin = 0
	
	if ( self.BounceWeaponIcon == true ) then
		fsin = 0
	end
	
	-- Borders
	y = y + 10
	x = x + 10
	wide = wide - 20
	
	-- Draw that mother
	surface.DrawTexturedRect( x + (fsin), y - (fsin),  wide-fsin*2 , ( wide / 2 ) + (fsin) )
	
	-- Draw weapon info box
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		if not IsValid( self ) or not IsValid( self:GetOwner() ) then return end
		
		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end
		
		if (not self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (not self.vRenderOrder) then
			
			-- we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (not v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (not v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (not pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				--model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() ~= v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin ~= model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) ~= v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:SetBodygroup( 0, self:GetSelectedMod() )
			self:DrawModel()
		end
		
		if (not self.WElements) then return end
		
		if (not self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			-- when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (not v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (not pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				--model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() ~= v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin ~= model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) ~= v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel ~= "") then
			
			local v = basetab[tab.rel]
			
			if (not v) then return end
			
			-- Technically, if there exists an element with the same name as a bone
			-- you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (not pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (not bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r -- Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (not tab) then return end

		-- Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model ~= "" and (not IsValid(v.modelEnt) or v.createdModel ~= v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spriteMaterial or v.createdSprite ~= v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				-- make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (not vm:GetBoneCount()) then return end
			
			-- !! WORKAROUND !! --
			-- We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (not hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			-- !! ----------- !! --
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (not bone) then continue end
				
				-- !! WORKAROUND !! --
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (not hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				-- !! ----------- !! --
				
				if vm:GetManipulateBoneScale(bone) ~= s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) ~= v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) ~= p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (not vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	-- Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	-- Does not copy entities of course, only copies their reference.
	-- WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (not tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) -- recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end
