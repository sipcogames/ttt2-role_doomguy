game.AddParticles( "particles/doom_vfx_weapons.pcf" )
PrecacheParticleSystem( "d_flamebelch" )

CreateClientConVar( "doom_melee_key", "0", true, true )
CreateClientConVar( "doom_grenade_key", "0", true, true )
CreateClientConVar( "doom_freezegrenade_key", "0", true, true )
CreateClientConVar( "doom_flamebelch_key", "0", true, true )
CreateClientConVar( "doom_crucible_key", "0", true, true )
CreateClientConVar( "doom_chainsaw_key", "0", true, true )

CreateConVar( "dredux_bloodpunch", "1", FCVAR_ARCHIVE )
CreateConVar( "dredux_playershavebloodpunch", "1", FCVAR_ARCHIVE )

CreateConVar( "dredux_grenade", "1", FCVAR_ARCHIVE )
CreateConVar( "dredux_playershavegrenade", "1", FCVAR_ARCHIVE )

CreateConVar( "dredux_freezegrenade", "1", FCVAR_ARCHIVE )
CreateConVar( "dredux_playershavefreezegrenade", "1", FCVAR_ARCHIVE )

CreateConVar( "dredux_flamebelch", "1", FCVAR_ARCHIVE )
CreateConVar( "dredux_playershaveflamebelch", "1", FCVAR_ARCHIVE )

CreateConVar( "dredux_keepeqondeath", "1", FCVAR_ARCHIVE )
CreateConVar( "dredux_fulleqspawn", "1", FCVAR_ARCHIVE )

-- Blood Punch
CreateConVar( "dredux_dmg_bloodpunch", "150" )

-- Equipment
CreateConVar( "dredux_dmg_frag", "125" )

	local function ChainsawCheck( ent )

		local num = ent:GetMaxHealth() / GetConVar( "dredux_dmg_mul" ):GetFloat()
		
		if ent:IsPlayer() then return 3 end
		
		if num < 200 then
			return 1
		elseif num < 500 then
			return 2
		else
			return 3
		end

	end
	
	----------------------------------------------------------------------------------------------------

	concommand.Add( "doom_weapons_unbind" , function( ply, cmd )
		ply:ConCommand( "doom_melee_key 0" )
		ply:ConCommand( "doom_grenade_key 0" )
		ply:ConCommand( "doom_freezegrenade_key 0" )
		ply:ConCommand( "doom_flamebelch_key 0" )
		ply:ConCommand( "doom_crucible_key 0" )
		ply:ConCommand( "doom_chainsaw_key 0" )
	end )

	local function DOOM_MeleeAttack( ply )

		local wep = ply:GetActiveWeapon()
		local lastwep = ply:GetActiveWeapon()
		
		if !ply.DOOM_NextMeleeAttack then ply.DOOM_NextMeleeAttack = CurTime() end
		if ply.DOOM_NextMeleeAttack > CurTime() then return end
		ply.DOOM_NextMeleeAttack = CurTime() + 0.75
			
		timer.Simple( 0, function()
		
				local bloodpunch = GetConVar( "dredux_bloodpunch" ):GetBool() && ( GetConVar( "dredux_playershavebloodpunch" ):GetBool() || ply:GetNW2Bool( "DOOM_HasBloodPunch" ) )
		
				if !IsValid( ply ) || !IsValid( wep ) || ( wep.NextHolster && wep.NextHolster > CurTime() ) || ply:GetActiveWeapon():GetClass() == "weapon_dredux_d2016_hands" then return end
				
				do
				
					if bloodpunch then
						
						local aim = ply:GetAimVector()
						local pos = ply:GetShootPos()

						local owner = ply

						local trdata = {}
						trdata.start = pos + aim
						trdata.endpos = pos + aim * 100
						trdata.mins = Vector( -80, -80, -80 )
						trdata.maxs = Vector( 80, 80, 80 )
						trdata.filter = function( ent ) return ent ~= ply && ent:Health() > 0 && ( ent:IsNPC() || ent:IsNextBot() || ent:IsPlayer() )end
						trdata.ignoreworld = true
						trdata.collisiongroup = COLLISION_GROUP_NONE

						local direction = util.TraceHull( trdata )
						
						if IsValid( direction.Entity ) && ( direction.Entity:IsNPC() || direction.Entity:IsNextBot() || direction.Entity:IsPlayer() ) && direction.Entity:Health() > 0 && ply:GetAmmoCount( "DOOM_BloodPunch" ) > 0 then
						
							ply:Give( "weapon_dredux_d2016_hands", true )
							ply:SelectWeapon( "weapon_dredux_d2016_hands" )
							
							if !( ply:GetActiveWeapon():GetClass() == "weapon_dredux_d2016_hands" ) then return end
							
							local wep = ply:GetActiveWeapon()
							
							wep:Deploy()
							wep.NextHolster = CurTime() + 0.5
							wep:OnDeploy( !lastwep.IsDOOMWeapon )
							wep:BloodPunch()
							
							wep:SetNextPrimaryFire( CurTime() + 1 )
							
							return
						
						end
						
					end
					
						if wep.IsDOOMWeapon then
						
							wep:MeleeAttack()
							
						else
						
							ply:Give( "weapon_dredux_d2016_hands", true )
							ply:SelectWeapon( "weapon_dredux_d2016_hands" )
							
							if !( ply:GetActiveWeapon():GetClass() == "weapon_dredux_d2016_hands" ) then return end
							
							local wep = ply:GetActiveWeapon()
							
							wep:Deploy()
							wep.NextHolster = CurTime() + 0.5
							wep:OnDeploy( true )
							wep:MeleeAttack()
							
							wep:SetNextPrimaryFire( CurTime() + 1 )
							
						end
					
				end
				
		end )
			
		timer.Simple( 0.6, function()
				if !IsValid( ply ) then return end
				if IsValid( lastwep ) && ply:HasWeapon( lastwep:GetClass() ) then
					ply:SelectWeapon( lastwep:GetClass() )
				end
				ply:StripWeapon( "weapon_dredux_d2016_hands" )
		end )

	end
		
	local function DOOM_Crucible( ply )
		
		if ply:GetActiveWeapon():GetClass() ~= "weapon_dredux_de_crucible" && ply:HasWeapon( "weapon_dredux_de_crucible" ) then
			ply:SelectWeapon( "weapon_dredux_de_crucible" )
			timer.Simple( 0.1, function()
				if !IsValid( ply ) then return end
				local wep = ply:GetActiveWeapon()
				if wep:GetClass() == "weapon_dredux_de_crucible" then
					wep:PrimaryAttack()
				end
			end )
		end

	end
	
	----------------------------------------------------------------------------------------------------
	
	local function DOOM_Chainsaw( ply )
	
		if !ply.DOOM_NextChainsaw then ply.DOOM_NextChainsaw = CurTime() end
		
		local lastwep = ply:GetActiveWeapon()
		
		if ply:Alive() && ply.DOOM_NextChainsaw <= CurTime() && ply:GetActiveWeapon():GetClass() ~= "weapon_dredux_d2016_chainsaw" && ply:HasWeapon( "weapon_dredux_d2016_chainsaw" ) then

			local aim = ply:GetAimVector()
			local pos = ply:GetShootPos()

			local owner = ply

			local trdata = {}
			trdata.start = pos + aim
			trdata.endpos = pos + aim * 300
			trdata.mins = Vector( -40, -40, -40 )
			trdata.maxs = Vector( 40, 40, 40 )
			trdata.filter = function( ent ) return ent ~= ply && ent:Health() > 0 && ( ent:IsNPC() || ent:IsNextBot() || ent:IsPlayer() )end
			trdata.ignoreworld = true
			trdata.collisiongroup = COLLISION_GROUP_NPC

			local direction = util.TraceHull( trdata )
			
			if IsValid( direction.Entity ) && !direction.Entity:GetNW2Bool( "DOOM_ChainsawImmune" ) && ( direction.Entity:IsNPC() || direction.Entity:IsNextBot() || direction.Entity:IsPlayer() ) && direction.Entity:Health() > 0 && ChainsawCheck( direction.Entity ) <= ply:GetAmmoCount( "DOOM_Chainsaw" ) && ply:Visible( direction.Entity ) then
			
				if direction.Entity:GetMaxHealth() > 2500*GetConVar( "dredux_dmg_mul" ):GetFloat() then return end
				if direction.Entity:IsPlayer() && !GetConVar( "dredux_chainsaw_pvp" ):GetFloat() then return end
				
				local wep = ply:GetWeapon( "weapon_dredux_d2016_chainsaw" )
				
				ply:SelectWeapon( "weapon_dredux_d2016_chainsaw" )
			
				timer.Simple( 0, function()
				
					if !IsValid( ply ) then return end
					local wep = ply:GetActiveWeapon()
					wep:PrimaryAttack()
						
						timer.Simple( 1, function()
						
							if !IsValid( ply ) then return end
							local wep = ply:GetActiveWeapon()
							
							if ply:HasWeapon( lastwep:GetClass() ) then
								ply:SelectWeapon( lastwep:GetClass() )
							end
							
						end )
					
				end )
				
			else
			
				ply:GetActiveWeapon():EmitSound( "doom/weapons/chainsaw/chainsaw_deploy.ogg", nil, nil, 1, CHAN_STATIC )
				ply.DOOM_NextChainsaw = CurTime() + 0.5
				
			end
			
		end

	end
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	local GrenadeLauncher = {}

	GrenadeLauncher.Type = "anim"
	GrenadeLauncher.Base = "base_anim"
	
	GrenadeLauncher.Model = "models/doom_eternal/weapons/equipment/equipment.mdl"

	GrenadeLauncher.Spawnable = false
	GrenadeLauncher.AutomaticFrameAdvance = true
	
	function GrenadeLauncher:Initialize()

		self:SetModel( self.Model )
		
		if SERVER then
		
			self:SetSolid( SOLID_NONE )
			self:SetUseType( SIMPLE_USE )
			
			self:DrawShadow( false )
		
		end
		
	end
	
	function GrenadeLauncher:Think()
	
		if ( SERVER ) then
			self:NextThink( CurTime() )
			return true
			
		else
		
			--self:SetNextClientThink( CurTime() + 1/250 )
			
		end
		
		local ply = self:GetOwner()
		self:SetPos( ply:GetShootPos() + ply:GetForward()*-12 + ply:GetUp()*-2 + ply:GetRight()*-6 )
			
	end
	
	scripted_ents.Register( GrenadeLauncher, "doom_eq_grenade_launcher" )
	
	----------------------------------------------------------------------------------------------------
	
	local function DOOM_GrenadeLauncher( ply )
	
		if IsValid( ply.DOOM_EquipmentLauncher ) then ply.DOOM_EquipmentLauncher:Remove() end
		local launcher = ents.Create( "doom_eq_grenade_launcher" )
		
		launcher:SetParent( ply )
		
		launcher:SetAngles( ply:GetAngles() - launcher:GetAngles() )
		
		
		launcher:Spawn()
		launcher:Activate()
		launcher:SetOwner( ply )
		
		launcher:SetPos( ply:GetShootPos() )
		
		--launcher:SetPos( ply:GetPos() + ply:GetForward()*-12 + ply:GetUp()*-2 + ply:GetRight()*-6 )
			
		timer.Simple( 0.25, function()
			if IsValid( launcher ) then
				launcher:ResetSequence( 1 )
			end
		end )
			
		timer.Simple( 0.75, function()
			if IsValid( launcher ) then
				launcher:Remove()
			end
		end )

		ply.DOOM_EquipmentLauncher = launcher
		
		return launcher
	
	end
	
	----------------------------------------------------------------------------------------------------
	
	local function DOOM_GrenadeLauncher_Attack( ply, proj, att, vel, spread )
	
		if CLIENT then return end
		
		local proj = proj or "rpg_missile"
		
		local vm = ply:GetViewModel()
		local aim = ply:GetAimVector()
		local pos = ply:GetShootPos()
		
		local spread = math.ceil( spread || 0 )

		local trdata = {}
		trdata.start = pos
		trdata.endpos = pos + aim * 10000
		trdata.filter = ply --function( ent ) return ent ~= self.Owner && ent:Owner() ~= self.Owner end
		trdata.collisiongroup = COLLISION_GROUP_PROJECTILE

		local targ = util.TraceLine( trdata )
		if !targ.Hit then 
			vel = aim:GetNormalized() * vel 
		else
			vel = ( targ.HitPos - att ):GetNormalized() * vel
		end

		local cur_proj = ents.Create( proj )
		cur_proj:SetPos( att )
		cur_proj:SetAngles( vel:Angle() )
		cur_proj:SetOwner( ply )
		
		cur_proj:Spawn()
		
		local phys = cur_proj:GetPhysicsObject()
		if IsValid( phys ) then
			phys:SetVelocity( vel + VectorRand()*math.random( spread ) )
		end
		
		return cur_proj
	
	end
	
	local Grenade = {}

	Grenade.Type = "anim"
	Grenade.Base = "proj_dredux_default"
	
	Grenade.Models = {"models/combine_helicopter/helicopter_bomb01.mdl"}
	Grenade.ModelScale = 0.2
	Grenade.Gravity = true
	Grenade.OnContactDecals = {--[["Scorch"]]}
	Grenade.OnContactDelete = 0.5
	
	function Grenade:CustomInitialize()
	
		ParticleEffectAttach( "d_rpg2rocket_trail_smoke", 1, self, 0)
		--ParticleEffectAttach( "d_rpg2lockonrocket_trail", 1, self, 0)
		
		self:DynamicLight( Color( 255, 150, 0 ), 50, 1 )
		
		if SERVER then
		
			util.SpriteTrail( self, 0, Color( 150, 150, 150, 10 ), false, 16, 0, 0.4, 1 / ( 16 + 0 ) * 0.4, "trails/smoke" )
			
			self:PhysicsInitSphere( 2 )
			self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
			
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetMass( 1 )
				phys:EnableDrag(false)
			end
			
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetColor( Color( 150, 150, 150 ) )

		end
		
	end
	
	function Grenade:Think()
	
		if ( self:WaterLevel() > 0 ) && SERVER then
			self:OnContact( game.GetWorld(), 0 )
			self:Remove()
		end
	
	end
	
	function Grenade:OnContact( ent, exp_time )
	
		if self.Exploded then return end
		self.Exploded = true
		
		if ent:Health() > 0 then exp_time = 0.1 end
	
		timer.Simple( exp_time or 0.25, function()
			
			if IsValid( self ) then
	
				local data = EffectData()
				data:SetOrigin( self:GetPos() )
				data:SetColor( 255 )
				data:SetMagnitude( 0 )
				data:SetScale( 1.5 )
				util.Effect( "dredux_explosion", data )
			
				self:EmitSound( "doom/weapons/shotgun/shotgun_grenade_explode"..math.random( 3 )..".ogg", 100, 90, nil, CHAN_WEAPON )
				self:EmitSound( "doom_eternal/weapons/rocketlauncher/rocket_explosion_"..math.random(2)..".ogg", 90, 100, 1 )
				
				
				util.ScreenShake( self:GetPos(), 50, 5, 0.5, 200 )

				local dmg = self:ScaleOutputDamage( "dredux_dmg_frag" ) + math.random( -5, 5 )
				
				if IsValid( ent ) then
					self:DealDamage( ent, dmg, DMG_BLAST )
				end
					
				self:RadiusDamage( dmg, DMG_BLAST, 300, function( argent ) return argent ~= ent && argent ~= self:GetOwner() end )
				
				self:Remove()
				
			end
		
		end )
		
	end
	
	function Grenade:Draw()
	
		self:DrawModel()
		
		render.SetMaterial( self.Effect_Glow )
		render.DrawSprite( self:GetPos(), 20, 20, Color( 255, 150, 0, 50 ) )
		
		--[[if self:GetNW2Bool( "DetonateRocket" ) then
		
			
			local normal = -EyeVector()
		
			render.SetMaterial( self.FlareMaterial )
			render.DrawQuadEasy( self:GetPos(), normal, 150, 100, Color( 255, 175, 0, 25 ), -5 )
		
		end]]
	
	end
	
	scripted_ents.Register( Grenade, "proj_dmod_eqgrenade" )
	
		local Grenade = {}

	Grenade.Type = "anim"
	Grenade.Base = "proj_dredux_default"
	
	Grenade.Models = {"models/combine_helicopter/helicopter_bomb01.mdl"}
	Grenade.ModelScale = 0.2
	Grenade.Gravity = true
	Grenade.OnContactDecals = {--[["Scorch"]]}
	Grenade.OnContactDelete = 0.5
	
	function Grenade:CustomInitialize()
	
		ParticleEffectAttach( "d_rpg2rocket_trail_smoke", 1, self, 0)
		--ParticleEffectAttach( "d_rpg2lockonrocket_trail", 1, self, 0)
		
		self:DynamicLight( Color( 255, 150, 0 ), 50, 1 )
		
		if SERVER then
		
			util.SpriteTrail( self, 0, Color( 150, 150, 150, 10 ), false, 16, 0, 0.4, 1 / ( 16 + 0 ) * 0.4, "trails/smoke" )
			
			self:PhysicsInitSphere( 2 )
			self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
			
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetMass( 1 )
				phys:EnableDrag(false)
			end
			
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetColor( Color( 100, 200, 255 ) )

		end
		
	end
	
	function Grenade:Think()
	
		if ( self:WaterLevel() > 0 ) && SERVER then
			self:OnContact( game.GetWorld(), 0 )
			self:Remove()
		end
	
	end
	
	function Grenade:OnContact( ent, exp_time )
	
		if self.Exploded then return end
		self.Exploded = true
		
		if ent:Health() > 0 then exp_time = 0.1 end
	
		timer.Simple( 0, function()
			
			if IsValid( self ) then
	
				local data = EffectData()
				data:SetOrigin( self:GetPos() )
				data:SetColor( 255 )
				data:SetMagnitude( 1 )
				data:SetScale( 1.25 )
				util.Effect( "dredux_explosion_freeze", data )
			
				self:EmitSound( "doom/weapons/shotgun/shotgun_grenade_explode"..math.random( 3 )..".ogg", 100, 90, nil, CHAN_STATIC )
				self:EmitSound( "doom_eternal/equipment/freeze_3.ogg", 100, 100, nil, CHAN_STATIC )
				self:EmitSound( "doom_eternal/equipment/freeze_"..math.random(2)..".ogg", 100, math.random( 95, 100 ), 1 )
				
				util.ScreenShake( self:GetPos(), 50, 5, 0.5, 200 )

				self:RadiusDamage( 0, DMG_BLAST, 175, function( argent ) return argent ~= self:GetOwner() end )
				self:Remove()
				
			end
		
		end )
		
	end
	
	function Grenade:DealDamage(ent, value, type, force )
	
		if ent == self then return end
		
		local dmg = DamageInfo()
		
		dmg:SetDamage(value)
		dmg:SetDamageForce( force || self:GetVelocity() )
		dmg:SetDamageType(type or DMG_DIRECT)
		
		if IsValid(self:GetOwner()) then
		
		  dmg:SetAttacker(self:GetOwner())
		  
		else dmg:SetAttacker(self) end
		
		if ( !ent:GetNW2Bool( "DOOM_ChainsawImmune" ) && ent:GetMaxHealth() < 6000*GetConVar( "dredux_dmg_mul" ):GetFloat() ) && ( ent:IsNPC() || ent:IsNextBot() || ent:IsPlayer() ) && ent:Health() > 0 then
		
			--ent:SetMaterial( "models/props_combine/stasisshield_sheet" )
			
			if IsValid( ent.DOOM_FreezeModel ) then ent.DOOM_FreezeModel:Remove() end
			
			local freeze = ents.Create( "base_anim" )
			
			freeze:SetModel( ent:GetModel() )
			--freeze:ManipulateBoneScale( 0, Vector( 1.1, 1.1, 1.1 ) )
			
			local mat = freeze:GetMaterials()
			
			for i = 0, #ent:GetBodyGroups() do
				freeze:SetBodygroup( i, ent:GetBodygroup( i ) )
			end
			
			for i = 0, #mat+1 do
				freeze:SetSubMaterial( i, "models/debug/debugwhite" )
			end
			
			freeze:SetRenderMode( RENDERMODE_TRANSCOLOR )
			freeze.RenderGroup = RENDERGROUP_TRANSLUCENT
			freeze:SetColor( Color( 100, 180, 255, 150 ) )
			
			freeze:SetPos( ent:GetPos() )
			freeze:SetAngles( ent:GetAngles() )
			
			freeze:SetParent( ent )
			freeze:SetOwner( ent )
			
			freeze:Spawn()
			
			freeze:AddEffects( bit.bor( EF_BONEMERGE, EF_BONEMERGE_FASTCULL ) )
			
			ParticleEffectAttach( "d_freezebomb", PATTACH_ABSORIGIN_FOLLOW, freeze, 0 )
			
			ent.DOOM_FreezeModel = freeze
			ent:DeleteOnRemove( freeze )
			
			ent.DOOM_Freezed = true
			
			timer.Simple( 5, function() 
				if IsValid( ent ) && ent.DOOM_Freezed then 
				
					if IsValid( ent.DOOM_FreezeModel ) then ent.DOOM_FreezeModel:Remove() end
					ent.DOOM_Freezed = false
					
				end
			end )
		
			if ent:IsNPC() then
			
				ent:NextThink( CurTime() + 5 )
				ent:ResetSequenceInfo()
				ent:ResetSequence( ent:GetSequence() )
				--ent:StopMoving()
				
			elseif ent.IsDrGNextbot then
				
				ent:NextThink( CurTime() + 5 )
				
			elseif ent.IsPlayer() then
			
				ent:Freeze( true )
				timer.Simple( 1, function() 
					if IsValid( ent ) then ent:Freeze( false ) end
					if IsValid( ent.DOOM_FreezeModel ) then ent.DOOM_FreezeModel:Remove() end
				end )
			
			else
			
				dmg:SetDamage( 100 )
			end
			
			ent:CallOnRemove( ent:EntIndex().."DOOM_FreezeRemove", function() ent:SetColor( Color( 255, 255, 255 ) ) ent:StopParticles() end, ent )
			
		end
		
		dmg:SetInflictor(self)
		dmg:SetDamagePosition( self:GetPos() )
		ent:TakeDamageInfo(dmg)
		
	end
	
	function Grenade:Draw()
	
		self:DrawModel()
		
		render.SetMaterial( self.Effect_Glow )
		render.DrawSprite( self:GetPos(), 20, 20, Color( 0, 150, 255, 50 ) )
		
		--[[if self:GetNW2Bool( "DetonateRocket" ) then
		
			
			local normal = -EyeVector()
		
			render.SetMaterial( self.FlareMaterial )
			render.DrawQuadEasy( self:GetPos(), normal, 150, 100, Color( 255, 175, 0, 25 ), -5 )
		
		end]]
	
	end
	
	scripted_ents.Register( Grenade, "proj_dmod_eqfreeze" )
	
	hook.Add( "OnNPCKilled", "FreezeRemove_OnNPCKilled", function( ent )
		if IsValid( ent.DOOM_FreezeModel ) then ent.DOOM_FreezeModel:Remove() end
	end )
	
	hook.Add( "DoPlayerDeath", "FreezeRemove_DoPlayerDeath", function( ent )
		if IsValid( ent.DOOM_FreezeModel ) then ent.DOOM_FreezeModel:Remove() end
	end )
	
	----------------------------------------------------------------------------------------------------

	local function DOOM_Grenade( ply )
		
		if !ply.DOOM_NextGrenade then ply.DOOM_NextGrenade = CurTime() end
		if !GetConVar( "dredux_grenade" ):GetBool() then return end
		
		if ply.DOOM_NextGrenade <= CurTime() && ply:GetAmmoCount( "DOOM_Grenade" ) > 0 && ( GetConVar( "dredux_playershavegrenade" ):GetBool() || ply:GetNW2Bool( "DOOM_HasGrenade" ) ) then
			
			local launcher = DOOM_GrenadeLauncher( ply )
			DOOM_GrenadeLauncher_Attack( ply, "proj_dmod_eqgrenade", ply:GetShootPos() + ply:GetAimVector()*15 + ply:GetRight()*-10 +ply:GetUp()*8, 1000 )
			
			ply:EmitSound( "doom_eternal/equipment/frag_fire.ogg", nil, nil, nil, CHAN_STATIC )
			
			ply:RemoveAmmo( 1, "DOOM_Grenade" )
			
			ply.DOOM_NextGrenade = CurTime() + 0.1
			
		end

	end
	
	local function DOOM_FreezeGrenade( ply )
		
		if !ply.DOOM_NextGrenade then ply.DOOM_NextGrenade = CurTime() end
		if !GetConVar( "dredux_freezegrenade" ):GetBool() then return end
		
		if ply.DOOM_NextGrenade <= CurTime() && ply:GetAmmoCount( "DOOM_FreezeGrenade" ) > 0 && ( GetConVar( "dredux_playershavefreezegrenade" ):GetBool() || ply:GetNW2Bool( "DOOM_HasFreezeGrenade" ) ) then
			
			local launcher = DOOM_GrenadeLauncher( ply )
			DOOM_GrenadeLauncher_Attack( ply, "proj_dmod_eqfreeze", ply:GetShootPos() + ply:GetAimVector()*15 + ply:GetRight()*-10 +ply:GetUp()*8, 1000 )
			
			ply:EmitSound( "doom_eternal/equipment/frag_fire.ogg", nil, 90, nil, CHAN_STATIC )
			
			ply:RemoveAmmo( 1, "DOOM_FreezeGrenade" )
			
			ply.DOOM_NextGrenade = CurTime() + 0.1
			
		end

	end
	
	local function DOOM_FlameBelch( ply )
		
		if !ply.DOOM_NextGrenade then ply.DOOM_NextGrenade = CurTime() end
		if !GetConVar( "dredux_flamebelch" ):GetBool() then return end
		
		if ply.DOOM_NextGrenade <= CurTime() && ply:GetAmmoCount( "DOOM_FlameBelch" ) > 0 && ( GetConVar( "dredux_playershaveflamebelch" ):GetBool() || ply:GetNW2Bool( "DOOM_HasFlameBelch" ) ) then
			
			local launcher = DOOM_GrenadeLauncher( ply )
			timer.Simple( 0, function() if IsValid( launcher ) then ParticleEffectAttach( "d_flamebelch", PATTACH_POINT_FOLLOW, launcher, 1 ) end end )
			
			--DOOM_GrenadeLauncher_Attack( ply, "proj_dmod_eqfreeze", ply:GetShootPos() + ply:GetAimVector()*15 + ply:GetRight()*-10 +ply:GetUp()*8, 1000 )
			
			local num = 10
			
			timer.Create( "DOOM_FlameBelch"..ply:EntIndex(), 0.5/num, num, function()
			
				local hitent = ply:TraceHullAttack( ply:GetShootPos(), ply:GetShootPos() + ply:GetAimVector() * 400, Vector( -20, -20, -20 ), Vector( 20, 20, 20 ), 0, DMG_BURN, 0, true )
				
				if IsValid( hitent ) then
					hitent:Ignite( hitent:IsPlayer() && 2 || 5 )
				end
				
			end )
			
			
			ply:EmitSound( "doom_eternal/equipment/flamebelch"..math.random(2)..".ogg", nil, 100, nil, CHAN_STATIC )
			
			ply:RemoveAmmo( 1, "DOOM_FlameBelch" )
			
			ply.DOOM_NextGrenade = CurTime() + 0.1
			
		end

	end
	
	
	----------------------------------------------------------------------------------------------------
	
	hook.Add ( "PlayerButtonDown", "DOOMPlayer_WeaponKeyBinds", function( ply, button )

		if button == ply:GetInfoNum( "doom_melee_key", 0 ) then
				
			if CLIENT then
				net.Start( "DOOM_MeleeAttack" ) net.SendToServer()
			else
				DOOM_MeleeAttack( ply )
			end
			
		end
		
		if button == ply:GetInfoNum( "doom_crucible_key", 0 ) then
				
			if CLIENT then
				net.Start( "DOOM_Crucible" ) net.SendToServer()
			else
				DOOM_Crucible( ply )
			end
			
		end
		
		if button == ply:GetInfoNum( "doom_chainsaw_key", 0 ) then
				
			if CLIENT then
				net.Start( "DOOM_Chainsaw" ) net.SendToServer()
			else
				DOOM_Chainsaw( ply )
			end
			
		end
		
		if button == tonumber( ply:GetInfo( "doom_grenade_key" ) )  then
				
			if CLIENT then
				net.Start( "DOOM_Grenade" ) net.SendToServer()
			else
				DOOM_Grenade( ply )
			end
			
		end
		
		if button == ply:GetInfoNum( "doom_freezegrenade_key", 0 ) then
				
			if CLIENT then
				net.Start( "DOOM_FreezeGrenade" ) net.SendToServer()
			else
				DOOM_FreezeGrenade( ply )
			end
			
		end
		
		if button == ply:GetInfoNum( "doom_flamebelch_key", 0 ) then
				
			if CLIENT then
				net.Start( "DOOM_FlameBelch" ) net.SendToServer()
			else
				DOOM_FlameBelch( ply )
			end
			
		end

	end )
	
	if SERVER then
		util.AddNetworkString( "DOOM_MeleeAttack" ) 
		util.AddNetworkString( "DOOM_Chainsaw" ) 
		util.AddNetworkString( "DOOM_Crucible" ) 
		util.AddNetworkString( "DOOM_Grenade" ) 
		util.AddNetworkString( "DOOM_FreezeGrenade" ) 
		util.AddNetworkString( "DOOM_FlameBelch" )
	else
	
		concommand.Add( "doom_bind", function( ply, cmd, args, str )
		
			--if !args then return end
			
			local command = args[1] .. " " .. input.GetKeyCode( args[2] )
			ply:ConCommand( command )
			
		end )
		
	end
	
	
	net.Receive( "DOOM_MeleeAttack", function( len, ply ) 
		DOOM_MeleeAttack( ply )
	end )
	
	net.Receive( "DOOM_Chainsaw", function( len, ply )
		DOOM_Chainsaw( ply )
	end )
	
	net.Receive( "DOOM_Crucible", function( len, ply ) 
		DOOM_Crucible( ply )
	end )
	
	net.Receive( "DOOM_Grenade", function( len, ply ) 
		DOOM_Grenade( ply )
	end )
	
	net.Receive( "DOOM_FreezeGrenade", function( len, ply ) 
		DOOM_FreezeGrenade( ply )
	end )
	
	net.Receive( "DOOM_FlameBelch", function( len, ply ) 
		DOOM_FlameBelch( ply )
	end )
	
	
hook.Add( "PlayerPostThink", "DOOM_Regen", function( ply )
	
	if SERVER && IsFirstTimePredicted() then

		if ply:HasWeapon( "weapon_dredux_d2016_chainsaw" ) && GetConVar( "dredux_infchainsaw" ):GetBool() then
	
			if ply:GetAmmoCount( "DOOM_Chainsaw" ) >= 1 then
				ply:SetNW2Float( "DOOM_Fuel", 0 )
			else
				ply:SetNW2Float( "DOOM_Fuel", ply:GetNW2Float( "DOOM_Fuel" ) + 0.075 )
				if ply:GetNW2Float( "DOOM_Fuel" ) >= 100 then
					ply:GiveAmmo( 1, "DOOM_Chainsaw", true )
				end
			end
			
		end
		
		if GetConVar( "dredux_bloodpunch" ):GetBool() then
			
			if !ply:GetNW2Float( "DOOM_BloodPunch" ) then ply:SetNW2Float( "DOOM_BloodPunch", 0 ) end
			
			if ply:GetNW2Float( "DOOM_BloodPunch" ) >= 100 then
				ply:GiveAmmo( 1, "DOOM_BloodPunch", true )
				ply:SetNW2Float( "DOOM_BloodPunch", 0 )
				ply:EmitSound( "doom/player/bpready_short.ogg", 80, 95, 1 )
			elseif ply:GetAmmoCount( "DOOM_BloodPunch" ) <= 0 then
				ply:SetNW2Float( "DOOM_BloodPunch", ply:GetNW2Float( "DOOM_BloodPunch" ) + 0.1 )
			end
		
		end
		
		if GetConVar( "dredux_grenade" ):GetBool() then
			
			if !ply:GetNW2Float( "DOOM_Grenade" ) then ply:SetNW2Float( "DOOM_Grenade", 0 ) end
			
			if ply:GetNW2Float( "DOOM_Grenade" ) >= 100 then
				ply:GiveAmmo( 1, "DOOM_Grenade", true )
				ply:SetNW2Float( "DOOM_Grenade", 0 )
				ply:EmitSound( "doom_eternal/equipment/grenade_ready.ogg" )
			elseif ply:GetAmmoCount( "DOOM_Grenade" ) <= 0 then
				ply:SetNW2Float( "DOOM_Grenade", ply:GetNW2Float( "DOOM_Grenade" ) + 0.11 )
			end
		
		end
		
		if GetConVar( "dredux_freezegrenade" ):GetBool() then
			
			if !ply:GetNW2Float( "DOOM_FreezeGrenade" ) then ply:SetNW2Float( "DOOM_FreezeGrenade", 0 ) end
			
			if ply:GetNW2Float( "DOOM_FreezeGrenade" ) >= 100 then
				ply:GiveAmmo( 1, "DOOM_FreezeGrenade", true )
				ply:SetNW2Float( "DOOM_FreezeGrenade", 0 )
				ply:EmitSound( "doom_eternal/equipment/grenade_ready.ogg" )
			elseif ply:GetAmmoCount( "DOOM_FreezeGrenade" ) <= 0 then
				ply:SetNW2Float( "DOOM_FreezeGrenade", ply:GetNW2Float( "DOOM_FreezeGrenade" ) + 0.075 )
			end
		
		end
		
		if GetConVar( "dredux_flamebelch" ):GetBool() then
			
			if !ply:GetNW2Float( "DOOM_FlameBelch" ) then ply:SetNW2Float( "DOOM_FlameBelch", 0 ) end
			
			if ply:GetNW2Float( "DOOM_FlameBelch" ) >= 100 then
				ply:GiveAmmo( 1, "DOOM_FlameBelch", true )
				ply:SetNW2Float( "DOOM_FlameBelch", 0 )
				ply:EmitSound( "doom_eternal/equipment/flamer_ready.ogg" )
			elseif ply:GetAmmoCount( "DOOM_FlameBelch" ) <= 0 then
				ply:SetNW2Float( "DOOM_FlameBelch", ply:GetNW2Float( "DOOM_FlameBelch" ) + 0.1 )
			end
		
		end
	
	end
	
end )
