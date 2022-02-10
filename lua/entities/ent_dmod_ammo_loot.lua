AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Spawnable = false

local LootBase = {}

	LootBase.Type = "anim"
	LootBase.Base = "base_gmodentity"
	
	LootBase.Model = "models/hunter/blocks/cube025x025x025.mdl"
	LootBase.Gravity = true
	
	LootBase.DeleteTime = 10
	
	LootBase.Color = Color( 255, 200, 0 )
	LootBase.PickupSound = "doom/pickups/ammo.ogg"
	
	LootBase.AmmoCount = 1
	LootBase.AmmoName = "none"
	
	LootBase.Spawnable = false
	
	LootBase.Icon = "effects/doom_eternal/loot/loot_ammo.png"
	LootBase.Icon2 = "effects/doom_eternal/loot/loot_ammo.png"
	
	LootBase.RenderGroup = RENDERGROUP_TRANSLUCENT
	
	
	function LootBase:Initialize()

		self:SetModel( self.Model )
		self:DrawShadow( false )

		if SERVER then
		
			util.SpriteTrail( self, 0, Color( self.Color.r, self.Color.g, self.Color.b, 255 ), false, 5, 0, 0.35, 1 / ( 10 + 0 ) * 0.5, "trails/smoke.vmt" )
			
			self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
		
			local phys = self:GetPhysicsObject()
			if(phys:IsValid()) then
				phys:Wake()
				phys:SetMass( 1 )
			end
		
			self:SetTrigger( true )
			self:UseTriggerBounds( true, 80 )
			
			if self.DeleteTime > 0 then
				timer.Simple( self.DeleteTime + math.Rand( -1, 1 ), function() if IsValid( self ) then self:Remove() end end )
			end
			
		else
		
			self.GlowSprite = Material( "particle/particle_glow_04.vmt" )
			self.BracketSprite = Material( "effects/doom_eternal/loot/loot_bracket.png", "smooth translucent" )
			self.IconSprite = Material( self.Icon, "smooth translucent" )
			self.IconSprite2 = Material( self.Icon2, "smooth translucent" )
			
		end
		
		self:OnInitialize()

	end
	
	function LootBase:OnInitialize()
	
	end
	
	function LootBase:Draw()
	
		--self:DrawModel()
		
		local pos = self:GetPos()
		
		render.SetMaterial( self.BracketSprite )
		render.DrawSprite( pos + Vector( 0, 0, 4 ), 12, 12, Color( self.Color.r, self.Color.g, self.Color.b, 255 ) )
		
		render.SetMaterial( self.IconSprite )
		render.DrawSprite( pos + Vector( 0, 0, 12 ), 12, 12, Color( self.Color.r, self.Color.g, self.Color.b, 255 ) )
		
		render.SetMaterial( self.IconSprite2 )
		render.DrawSprite( pos + Vector( 0, 0, 4 ), 8, 8, Color( self.Color.r, self.Color.g, self.Color.b, 255 ) )
		
		render.SetMaterial( self.GlowSprite )
		render.DrawSprite( pos , 64, 64, Color( self.Color.r, self.Color.g, self.Color.b, 15 ) )
	
	end
	
	function LootBase:Think()
	
	end
	
	function LootBase:StartTouch( ent )
	
		if ent:IsPlayer() then
		
			ent:GiveAmmo( self.AmmoCount, self.AmmoName )
			self:EmitSound( self.PickupSound )
			self:Remove()
			
		end
	
	end
	
	scripted_ents.Register( LootBase, "doom_loot_base" )
	
----------------------------------------------------------------------------------------------------
	
local Loot1 = {}

	Loot1.Type = "anim"
	Loot1.Base = "doom_loot_base"
	Loot1.Icon2 = "effects/doom_eternal/loot/ico_shells.png"

	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	Loot1.AmmoCount = 5
	Loot1.AmmoName = "buckshot"
	
	Loot1.Color = Color( 255, 220, 0 ) --Color( 255, 200, 0 )
	
	scripted_ents.Register( Loot1, "doom_loot_buckshot" )
	
local Loot2 = {}

	Loot2.Type = "anim"
	Loot2.Base = "doom_loot_base"
	Loot2.Icon2 = "effects/doom_eternal/loot/ico_bullets.png"

	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	Loot2.AmmoCount = 20
	Loot2.AmmoName = "smg1"
	
	Loot2.Color = Color( 255, 220, 50 ) -- Color( 100, 255, 50 )
	
	scripted_ents.Register( Loot2, "doom_loot_bullet" )
	
local Loot3 = {}

	Loot3.Type = "anim"
	Loot3.Base = "doom_loot_base"
	Loot3.Icon2 = "effects/doom_eternal/loot/ico_cell.png"

	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	Loot3.AmmoCount = 20
	Loot3.AmmoName = "ar2"
	
	Loot3.Color = Color( 255, 220, 50 ) -- Color( 225, 125, 255 )
	
	scripted_ents.Register( Loot3, "doom_loot_plasma" )
	
local Loot4 = {}

	Loot4.Type = "anim"
	Loot4.Base = "doom_loot_base"
	Loot4.Icon2 = "effects/doom_eternal/loot/ico_rocket.png"

	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	Loot4.AmmoCount = 2
	Loot4.AmmoName = "rpg_round"
	
	Loot4.Color = Color( 255, 220, 50 ) -- Color( 255, 100, 50 )
	
	scripted_ents.Register( Loot4, "doom_loot_rocket" )
	
local Loot5 = {}

	Loot5.Type = "anim"
	Loot5.Base = "doom_loot_base"
	Loot5.Icon = "effects/doom_eternal/loot/ico_energy.png"
	Loot5.Icon2 = "effects/doom_eternal/loot/ico_bfg.png"

	Loot5.PickupSound = "doom/pickups/bfg.ogg"
	
	Loot5.AmmoCount = 1
	Loot5.AmmoName = "DOOM_BFG"
	
	Loot5.Color = Color( 100, 255, 50 )
	
	function Loot5:StartTouch( ent )
	
		if ent:IsPlayer() then
		
			ent:GiveAmmo( math.Clamp( 15, 0, 60-ent:GetAmmoCount( self.AmmoName ) ), self.AmmoName )
			self:EmitSound( self.PickupSound )
			self:Remove()
			
		end
	
	end
	
	
	scripted_ents.Register( Loot5, "doom_loot_bfg" )
	
local Loot6 = {}

	Loot6.Type = "anim"
	Loot6.Base = "doom_loot_base"
	Loot6.Icon = "effects/doom_eternal/loot/loot_health.png"
	Loot6.Icon2 = "effects/doom_eternal/loot/item_health.png"
	
	Loot6.DeleteTime = 25

	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	Loot6.PickupSound = "doom/pickups/hp_1.ogg"
	
	Loot6.Color = Color( 0, 225, 255 )
	
	function Loot6:StartTouch( ent )
	
		if ent:IsPlayer() && ent:Health() < ent:GetMaxHealth() then
		
			ent:SetHealth( math.Clamp( ent:Health()+4+math.random(1), 0, ent:GetMaxHealth() ) )
			self:EmitSound( self.PickupSound )
			self:Remove()
			
		end
	
	end
	
	function Loot6:Draw()
	
		--self:DrawModel()
		
		local pos = self:GetPos()
		
		--[[render.SetMaterial( self.BracketSprite )
		render.DrawSprite( pos + Vector( 0, 0, 0 ), 15, 15, Color( self.Color.r, self.Color.g, self.Color.b, 200 ) )
				
		render.SetMaterial( self.IconSprite2 )
		render.DrawSprite( pos + Vector( 0, 0, 0 ), 12, 12, Color( self.Color.r, self.Color.g, self.Color.b, 255 ) )
		
		render.SetMaterial( self.IconSprite )
		render.DrawSprite( pos + Vector( 0, 0, 10 ), 12, 12, Color( self.Color.r, self.Color.g, self.Color.b, 255 ) )]]
		
		render.SetMaterial( self.IconSprite2 )
		render.DrawSprite( pos + Vector( 0, 0, 0.5 ), 10, 10, Color( self.Color.r, self.Color.g, self.Color.b, 255 ) )
		
		render.SetMaterial( self.BracketSprite )
		render.DrawSprite( pos + Vector( 0, 0, 0 ), 15, 15, Color( self.Color.r, self.Color.g, self.Color.b, 200 ) )
		
		render.SetMaterial( self.GlowSprite )
		render.DrawSprite( pos , 40, 40, Color( self.Color.r, self.Color.g, self.Color.b, 30 ) )
	
	end
	
	scripted_ents.Register( Loot6, "doom_loot_hp" )
	
local Loot6 = {}

	Loot6.Type = "anim"
	Loot6.Base = "doom_loot_hp"
	Loot6.Icon = "effects/doom_eternal/loot/loot_armor.png"
	Loot6.Icon2 = "effects/doom_eternal/loot/item_armor.png"

	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	Loot6.PickupSound = "doom/pickups/armor_1.ogg"
	
	Loot6.Color = Color( 100, 255, 50 )
	
	function Loot6:StartTouch( ent )
	
		if ent:IsPlayer() && ent:Armor() < ent:GetMaxArmor() then
		
			ent:SetArmor( math.Clamp( ent:Armor()+5, 0, ent:GetMaxArmor() ) )
			self:EmitSound( self.PickupSound )
			self:Remove()
			
		end
	
	end
	
	scripted_ents.Register( Loot6, "doom_loot_armor" )
	
----------------------------------------------------------------------------------------------------
	
local Loot_Shotgun2 = {}

	Loot_Shotgun2.Type = "anim"
	Loot_Shotgun2.Base = "doom_loot_buckshot"
	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	Loot_Shotgun2.AmmoCount = 2
	Loot_Shotgun2.AmmoName = "buckshot"
	
	function Loot_Shotgun2:OnInitialize()
	
		self.Time = 0
	
	end
	
	function Loot_Shotgun2:Think()
	
		self.Time = self.Time + 1
		if self.Time > 10 then return end
	
		local owner = self:GetOwner()
		if !IsValid( owner ) then return end
		
		local vel = ( ( owner:GetPos() + owner:OBBCenter() + owner:GetVelocity() * 0.25 ) - self:GetPos() ):GetNormalized() * 200
		
		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:AddVelocity( vel + Vector( 0, 0, 1 ) )
		end
	
	end
	
	scripted_ents.Register( Loot_Shotgun2, "doom_loot_buckshot2" )
	
----------------------------------------------------------------------------------------------------
	
local PickupBase = {}

	PickupBase.Type = "anim"
	PickupBase.Base = "base_gmodentity"
	
	PickupBase.Model = ""
	PickupBase.Gravity = true
	
	PickupBase.DeleteTime = -1
	
	PickupBase.Color = Color( 255, 175, 0 )
	PickupBase.OutlineColor = Color( 255, 175, 0 )
	PickupBase.PickupSound = "doom/pickups/ammo.ogg"
	
	PickupBase.AmmoCount = 1
	PickupBase.AmmoName = "none"
	
	PickupBase.Spawnable = false
	
	PickupBase.Icon = "effects/doom_eternal/loot/loot_ammo.png"
	PickupBase.Glow = 0
	PickupBase.GlowOffset = Vector()
	
	function PickupBase:Initialize()

		self:SetModel( self.Model )

		if SERVER then
		
			self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			self:PhysicsInit( self.Gravity && SOLID_VPHYSICS || SOLID_NONE )
			self:SetMoveType( self.Gravity && MOVETYPE_VPHYSICS || MOVETYPE_NONE )
			self:SetSolid( SOLID_VPHYSICS )
		
			local phys = self:GetPhysicsObject()
			if(phys:IsValid()) then
				phys:Wake()
			end
		
			self:SetTrigger( true )
			self:UseTriggerBounds( true, 24 )
			
		else
		
			self.GlowSprite = Material( "particle/particle_glow_04.vmt" )
			
		end
		
		self:OnInitialize()

	end
	
	function PickupBase:OnInitialize()
	
	end
	
	function PickupBase:Draw()
	
		self:DrawModel()
		
		local pos = self:GetPos()
		
		if self.Glow > 0 then
		
			render.SetMaterial( self.GlowSprite )
			render.DrawSprite( pos + self.GlowOffset, self.Glow, self.Glow, Color( self.Color.r, self.Color.g, self.Color.b, 25 ) )
			
		end
	
	end
	
	function PickupBase:StartTouch( ent )
	
		if ent:IsPlayer() then
		
			ent:GiveAmmo( self.AmmoCount, self.AmmoName )
			self:EmitSound( self.PickupSound )
			self:Remove()
			
		end
	
	end
	
	scripted_ents.Register( PickupBase, "doom_pickup_base" )
	
----------------------------------------------------------------------------------------------------

local Crucible_Charge = {}

	Crucible_Charge.PrintName = "Crucible Charge"

	Crucible_Charge.Type = "anim"
	Crucible_Charge.Base = "doom_pickup_base"
	Crucible_Charge.Model = "models/doom_eternal/pickups/crucible_charge.mdl"
	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	Crucible_Charge.Spawnable = true
	Crucible_Charge.Category = "DOOM Eternal"
	
	Crucible_Charge.PickupSound = "doom/pickups/gas.ogg"
	
	Crucible_Charge.Gravity = false
	
	Crucible_Charge.AmmoCount = 1
	Crucible_Charge.AmmoName = "DOOM_Crucible"
	
	Crucible_Charge.DeleteTime = -1
	
	Crucible_Charge.Color = Color( 255, 0, 0 )
	Crucible_Charge.OutlineColor = Color( 0, 0, 0 )
	Crucible_Charge.Glow = 75
	Crucible_Charge.GlowOffset = Vector( 0, 0, 40 )
	
	
	function Crucible_Charge:StartTouch( ent )
	
		if ent:IsPlayer() then
		
			ent:GiveAmmo(  math.Clamp( 1, 0, 3-ent:GetAmmoCount( self.AmmoName ) ), self.AmmoName )
			self:EmitSound( self.PickupSound, nil, 90 )
			self:Remove()
			
		end
	
	end
	
	scripted_ents.Register( Crucible_Charge, "doom_idpickup_crucible_charge" )
	if CLIENT then language.Add( "DOOM_Crucible_ammo", "Crucible Charge" ) end
	
----------------------------------------------------------------------------------------------------
	
local BloodPunch = {}

	BloodPunch.PrintName = "Blood Punch"

	BloodPunch.Type = "anim"
	BloodPunch.Base = "doom_pickup_base"
	BloodPunch.Model = "models/doom_eternal/pickups/bloodpunch_pickup_a.mdl"
	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	BloodPunch.Spawnable = true
	BloodPunch.Category = "DOOM Eternal"
	
	BloodPunch.PickupSound = "doom/pickups/bp.ogg"
	
	BloodPunch.Gravity = false
	
	BloodPunch.AmmoCount = 1
	BloodPunch.AmmoName = "DOOM_BloodPunch"
	
	BloodPunch.DeleteTime = -1
	
	BloodPunch.Color = Color( 255, 200, 0 )
	BloodPunch.OutlineColor = Color( 0, 0, 0 )
	BloodPunch.Glow = 64
	BloodPunch.GlowOffset = Vector( 0, 0, 35 )
	
	BloodPunch.NW2 = "DOOM_HasBloodPunch"
	
	function BloodPunch:OnInitialize()
	
		self:DrawShadow( false )
		self:SetModelScale( 0.75 )
		
		self:SetAngles( self:GetAngles() + Angle( 0, math.random( 360 ), 0 ) )
	
	end
	
	
	function BloodPunch:Think()
	
		if CLIENT then
		
			self:SetAngles( self:GetAngles() + Angle( 0, 1, 0 ) )
			self:SetNextClientThink( CurTime() + 1/60 )
		
		end
	
	end
	
	function BloodPunch:StartTouch( ent )
	
		if ent:IsPlayer() then
		
			ent:GiveAmmo(  math.Clamp( 1, 0, 1-ent:GetAmmoCount( self.AmmoName ) ), self.AmmoName, true )
			ent:SetNW2Bool( self.NW2, true )
			
			self:EmitSound( self.PickupSound, nil, 100 )
			self:Remove()
			
		end
	
	end
	
	scripted_ents.Register( BloodPunch, "doom_idpickup_bloodpunch" )
	
local Grenade = {}

	Grenade.PrintName = "Frag Grenade"

	Grenade.Type = "anim"
	Grenade.Base = "doom_idpickup_bloodpunch"
	Grenade.Model = "models/doom_eternal/pickups/equipment_launcher_pickup.mdl"
	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	Grenade.Spawnable = true
	Grenade.Category = "DOOM Eternal"
	
	Grenade.PickupSound = Crucible_Charge.PickupSound
	
	Grenade.Gravity = false
	
	Grenade.AmmoCount = 1
	Grenade.AmmoName = "DOOM_Grenade"
	
	Grenade.DeleteTime = -1
	
	Grenade.Color = Color( 255, 150, 0 )
	Grenade.Glow = 64
	Grenade.GlowOffset = Vector( 0, 0, 32.5 )
	
	Grenade.GrenadeType = 0
	Grenade.NW2 = "DOOM_HasGrenade"
	
	function Grenade:OnInitialize()
	
		self:DrawShadow( false )
		self:SetModelScale( 1.5 )
		
		self:SetCollisionBounds( Vector( -15, -15, -5 ), Vector( 15, 15, 60 ) )
		
		self:SetBodygroup( 1, self.GrenadeType  )
		
		self:SetAngles( self:GetAngles() + Angle( 0, math.random( 360 ), 0 ) )
	
	end
	
	scripted_ents.Register( Grenade, "doom_idpickup_frag" )
	
local Grenade = {}

	Grenade.PrintName = "Flame Belch"

	Grenade.Type = "anim"
	Grenade.Base = "doom_idpickup_frag"
	Grenade.Model = "models/doom_eternal/pickups/equipment_launcher_pickup.mdl"
	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	Grenade.Spawnable = true
	Grenade.Category = "DOOM Eternal"
	
	Grenade.AmmoName = "DOOM_FlameBelch"
	
	Grenade.GrenadeType = 1
	Grenade.NW2 = "DOOM_HasFlameBelch"
	
	scripted_ents.Register( Grenade, "doom_idpickup_flamebelch" )
	
local Grenade = {}

	Grenade.PrintName = "Freeze Bomb"

	Grenade.Type = "anim"
	Grenade.Base = "doom_idpickup_frag"
	Grenade.Model = "models/doom_eternal/pickups/equipment_launcher_pickup.mdl"
	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	Grenade.Spawnable = true
	Grenade.Category = "DOOM Eternal"
	
	Grenade.AmmoName = "DOOM_FreezeGrenade"
	
	Grenade.GrenadeType = 2
	Grenade.NW2 = "DOOM_HasFreezeGrenade"
	
	scripted_ents.Register( Grenade, "doom_idpickup_freezebomb" )
	
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
local Fuel = {}

	Fuel.PrintName = "Chainsaw Fuel"

	Fuel.Type = "anim"
	Fuel.Base = "doom_pickup_base"
	Fuel.Model = "models/doom/pickups/ammo/gas_large_max.mdl"
	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	Fuel.Spawnable = true
	Fuel.Category = "DOOM 2016"
	
	Fuel.PickupSound = "doom/pickups/gas.ogg"
	
	Fuel.AmmoName = "DOOM_Chainsaw"
	
	Fuel.DeleteTime = -1
	
	Fuel.Color = Color( 255, 200, 0 )
	Fuel.Glow = 0
	
	
	function Fuel:StartTouch( ent )
	
		if ent:IsPlayer() then
		
			ent:GiveAmmo(  math.Clamp( 1, 0, 3-ent:GetAmmoCount( self.AmmoName ) ), self.AmmoName )
			self:EmitSound( self.PickupSound, nil, 90 )
			self:Remove()
			
		end
	
	end
	
	scripted_ents.Register( Fuel, "doom_pickup_fuel1" )
	if CLIENT then language.Add( "DOOM_Chainsaw_ammo", "Chainsaw Fuel" ) end
	
----------------------------------------------------------------------------------------------------

local BFGAmmo = {}

	BFGAmmo.PrintName = "BFG Ammo"

	BFGAmmo.Type = "anim"
	BFGAmmo.Base = "doom_pickup_base"
	BFGAmmo.Model = "models/doom/pickups/ammo/bfg_ammo.mdl"
	--Loot_Shotgun.PickupSound = "doom/ammo.ogg"
	
	BFGAmmo.Spawnable = true
	BFGAmmo.Category = "DOOM 2016"
	
	BFGAmmo.PickupSound = "doom/pickups/bfg.ogg"
	
	BFGAmmo.AmmoName = "DOOM_BFG"
	
	BFGAmmo.DeleteTime = -1
	
	BFGAmmo.Color = Color( 25, 200, 0 )
	BFGAmmo.Glow = 0
	
	
	function BFGAmmo:StartTouch( ent )
	
		if ent:IsPlayer() then
		
			ent:GiveAmmo(  math.Clamp( 30, 0, 60-ent:GetAmmoCount( self.AmmoName ) ), self.AmmoName )
			self:EmitSound( self.PickupSound, nil, 90 )
			self:Remove()
			
		end
	
	end
	
	scripted_ents.Register( BFGAmmo, "doom_pickup_bfg1" )
	if CLIENT then language.Add( "DOOM_BFG_ammo", "BFG Ammo" ) end
	
----------------------------------------------------------------------------------------------------
	
hook.Add( "PreDrawHalos", "DOOM_PickupHalos", function()
	local ents = ents.FindByClass( "doom_pickup_*" )
	halo.Add( ents, Color( 255, 200, 0, 255 ), 1, 3, 3, true )
end )
	
	
	
	
	
	
	
	
	