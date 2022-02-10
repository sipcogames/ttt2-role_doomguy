----------------------------------------------------------------------------------------------------
-- INIT
----------------------------------------------------------------------------------------------------

AddCSLuaFile()

include( "dredux_equipment.lua" )
include( "dredux_gk.lua" )

AddCSLuaFile( "dredux_equipment.lua" )
AddCSLuaFile( "dredux_gk.lua" )

if !DModRedux then DModRedux = {} end

DModRedux.DOOMWeapons = {}
DModRedux.DOOMWeapons_WeaponMods = {}

--

function DModRedux:SetWeaponMod( ply, WeaponMod, value )
	if !ply.DOOM_WeaponMods then ply.DOOM_WeaponMods = {} end
	--if isbool( value ) then ply:SetNWBool( WeaponMod, value ) end
	
	ply.DOOM_WeaponMods[ WeaponMod ] = value
	
end

function DModRedux:GetWeaponMod( ply, WeaponMod )

	if GetConVar( "dredux_allweaponmods" ):GetBool() && GetConVar( "dredux_weaponmods" ):GetBool() then return true end
	if !ply.DOOM_WeaponMods then return false end
	
	return ply.DOOM_WeaponMods[ WeaponMod ]
	
end

--

hook.Add( "PostPlayerDeath", "RemoveWeaponMods", function( ply )

	if !GetConVar( "dredux_keepweaponmods" ):GetBool() then
		ply.DOOM_WeaponMods = {}
	end
	
	if !GetConVar( "dredux_keepeqondeath" ):GetBool() then
		ply:SetNW2Bool( "DOOM_HasBloodPunch", false )
		ply:SetNW2Bool( "DOOM_HasGrenade", false )
		ply:SetNW2Bool( "DOOM_HasFreezeGrenade", false )
		ply:SetNW2Bool( "DOOM_HasFlameBelch", false )
	end
	
end )

hook.Add( "HUDWeaponPickedUp", "DOOM_HideWeapon", function( weapon )
	local class = weapon:GetClass()
	if class == "weapon_dredux_d2016_hands" then return false end
end )

--

if CLIENT then

	include( "matproxy/dredux_weapons_matproxy.lua" )
	
	local function DOOMWeapons_MenuMain( Panel )
	
		Panel:SetName( "Admin Weapons options" )
		Panel:ControlHelp( "Only admins can change these settings!" )
	
		if game.SinglePlayer() || ( LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) then
	
			Panel:AddControl( "Slider", { Label = "Damage Multiplier:", Command ="dredux_dmg_mul", Min = "0.5", Max = "5", type = "float" } )
			Panel:ControlHelp( "This option also affects chainsaw fuel consumption" )
			
			Panel:AddControl( "Slider", { Label = "Force Player Loadout", Command ="dredux_startweapon", Min = "0", Max = "4" } )
			Panel:ControlHelp( "0: No weapons" )
			Panel:ControlHelp( "1: DOOM 2016 start weapons" )
			Panel:ControlHelp( "2: DOOM 2016 full loadout" )
			Panel:ControlHelp( "3: DOOM Eternal start weapons" )
			Panel:ControlHelp( "4: DOOM Eternal full loadout" )
			
			Panel:AddControl( "Checkbox", { Label = "Remove sandbox weapons in DOOM loadouts?", Command = "dredux_loadout_nosandboxweps" } )
			Panel:AddControl( "Checkbox", { Label = "No super weapons in DOOM loadouts?", Command = "dredux_loadout_nosuperweps" } )
			Panel:AddControl( "Checkbox", { Label = "DE Plasma rifle in DOOM loadouts?", Command = "dredux_loadout_deplasma" } )

			Panel:ControlHelp( "" )
			Panel:ControlHelp( "" )

			Panel:AddControl( "Checkbox", { Label = "Enable weapon intro sequences?", Command = "dredux_intro" } )
			
			--
			
			Panel:ControlHelp( "" )
			Panel:ControlHelp( "" )
			
			Panel:AddControl( "Checkbox", { Label = "Enable weapon mods?", Command = "dredux_weaponmods" } )
			Panel:AddControl( "Checkbox", { Label = "Players have all weapon mods by default?", Command = "dredux_allweaponmods" } )
			Panel:ControlHelp( "Makes players unable to use modbots!" )
			
			Panel:AddControl( "Checkbox", { Label = "Players keep weapon mods on death?", Command = "dredux_keepweaponmods" } )
			Panel:AddControl( "Checkbox", { Label = "Modbots have infinite amount of weapon mods?", Command = "dredux_infiniteweaponmods" } )
			
			Panel:ControlHelp( "" )
			Panel:ControlHelp( "" )
			
			Panel:AddControl( "Checkbox", { Label = "Disable Double Trouble mastery on DOOM 2016 SSG?", Command = "dredux_nodoubletrouble" } )
			--Panel:AddControl( "Checkbox", { Label = "Slower Quick-Scoping?", Command = "dredux_noquickscope" } )
			Panel:AddControl( "Checkbox", { Label = "Enable gauss/ballista boost?", Command = "dredux_gaussjump" } )
			Panel:AddControl( "Checkbox", { Label = "Chainsaw Regeneration?", Command = "dredux_infchainsaw" } )
			Panel:AddControl( "Checkbox", { Label = "Chainsaw & Crucible target players?", Command = "dredux_chainsaw_pvp" } )
			
			Panel:ControlHelp( "" )
			Panel:ControlHelp( "" )
			
			Panel:AddControl( "Checkbox", { Label = "Enable Blood Punch?", Command = "dredux_bloodpunch" } )
			Panel:AddControl( "Checkbox", { Label = "Players have Blood Punch by default?", Command = "dredux_playershavebloodpunch" } )
			Panel:ControlHelp( "" )
			
			Panel:AddControl( "Checkbox", { Label = "Enable Frag Grenade?", Command = "dredux_grenade" } )
			Panel:AddControl( "Checkbox", { Label = "Players have Frag Grenade by default?", Command = "dredux_playershavegrenade" } )
			Panel:ControlHelp( "" )
			
			Panel:AddControl( "Checkbox", { Label = "Enable Flame Belch?", Command = "dredux_flamebelch" } )
			Panel:AddControl( "Checkbox", { Label = "Players have Flame Belch by default?", Command = "dredux_playershaveflamebelch" } )
			Panel:ControlHelp( "" )
			
			Panel:AddControl( "Checkbox", { Label = "Enable Freeze Bomb?", Command = "dredux_freezegrenade" } )
			Panel:AddControl( "Checkbox", { Label = "Players have Freeze Bomb by default?", Command = "dredux_playershavefreezegrenade" } )
			Panel:ControlHelp( "" )
			
			Panel:AddControl( "Checkbox", { Label = "Players keep equipment on death?", Command = "dredux_keepeqondeath" } )
			
			Panel:ControlHelp( "" )
			Panel:ControlHelp( "" )
			
			--
			
			Panel:AddControl( "Checkbox", { Label = "BFG admin-only?", Command = "dredux_bfg_restricted" } )
			Panel:AddControl( "Checkbox", { Label = "BFG damages players?", Command = "dredux_bfg_damageplayers" } )
			Panel:AddControl( "Checkbox", { Label = "BFG rays damage players?", Command = "dredux_bfg_rays_damageplayers" } )
			
			Panel:AddControl( "Checkbox", { Label = "Unmaker admin-only?", Command = "dredux_unmaker_restricted" } )
			
			Panel:ControlHelp( "" )
			
		end
	
	end
	
	local function DOOMWeapons_MenuClient( Panel )
	
		Panel:SetName( "DOOM Weapons options ( Client )" )
		
		Panel:ControlHelp( "" )
		
		Panel:AddControl( "Numpad", { Label = "Frag Grenade:", Command = "doom_grenade_key" } )
		Panel:AddControl( "Numpad", { Label = "Freeze Bomb:", Command = "doom_freezegrenade_key" } )
		Panel:AddControl( "Numpad", { Label = "Flame Belch:", Command = "doom_flamebelch_key" } )
		
		Panel:ControlHelp( "" )
		Panel:AddControl( "Numpad", { Label = "Melee Attack:", Command = "doom_melee_key" } )		
		Panel:AddControl( "Numpad", { Label = "Chainsaw:", Command = "doom_chainsaw_key" } )
		Panel:AddControl( "Numpad", { Label = "Crucible:", Command = "doom_crucible_key" } )
	
		Panel:AddControl( "Button", { Label = "Unbind All", Command = "doom_weapons_unbind" } )
		
		Panel:ControlHelp( "" )
		Panel:ControlHelp( "" )
		
		--
		
		Panel:AddControl( "Slider", { Label = "Crosshair Scale", Command ="cl_dredux_crosshairscale", Min = "0.5", Max = "1.5", type = "float" } )
		Panel:AddControl( "Checkbox", { Label = "Enable DOOM-style sway?", Command = "cl_dredux_bob" } )
		Panel:AddControl( "Checkbox", { Label = "Enable envmap reflections?", Command = "cl_dredux_reflections" } )
		
		
		
		--
		
		--Panel:AddControl( "Color", { Label = "Crosshair Color", Command = "cl_dredux_reflections" } )
		--Panel:AddControl( "Checkbox", { Label = "Crosshair color affects D2016 crosshairs?", Command = "cl_dredux_reflections" } )
		
		
		
		
	
	end
	
	
	hook.Add( "PopulateToolMenu", "DOOMWeapons_Menu", function()
		
		spawnmenu.AddToolMenuOption( "Utilities", "DOOM", "DOOM_AdminWeaponOptions", "Admin Weapon Options", "", "", DOOMWeapons_MenuMain, {} )
		spawnmenu.AddToolMenuOption( "Utilities", "DOOM", "DOOM_WeaponOptions", "Weapon Options", "", "", DOOMWeapons_MenuClient, {} )

	end )
	
end

----------------------------------------------------------------------------------------------------
-- INIT END
----------------------------------------------------------------------------------------------------

CreateClientConVar( "cl_dredux_weapons_centered", "0", true )

--

CreateClientConVar( "cl_dredux_reflections", "1", true )
CreateClientConVar( "cl_dredux_reflections_env_cubemap", "0", true )
CreateClientConVar( "cl_dredux_crosshairscale", "1", true )
CreateClientConVar( "cl_dredux_bob", "1", true )

-- Weapon Mods
	
CreateConVar( "dredux_weaponmods", "1", FCVAR_ARCHIVE )
CreateConVar( "dredux_allweaponmods", "1", FCVAR_ARCHIVE )
CreateConVar( "dredux_keepweaponmods", "1", FCVAR_ARCHIVE )
CreateConVar( "dredux_infiniteweaponmods", "0", FCVAR_ARCHIVE )

CreateConVar( "dredux_startweapon", "0", FCVAR_ARCHIVE )
CreateConVar( "dredux_loadout_nosandboxweps", "1", FCVAR_ARCHIVE )
CreateConVar( "dredux_loadout_nosuperweps", "0", FCVAR_ARCHIVE )
CreateConVar( "dredux_loadout_deplasma", "0", FCVAR_ARCHIVE )

CreateConVar( "dredux_nodoubletrouble", "0", FCVAR_ARCHIVE )
CreateConVar( "dredux_noquickscope", "0", FCVAR_ARCHIVE )
CreateConVar( "dredux_gaussjump", "1", FCVAR_ARCHIVE )
CreateConVar( "dredux_infchainsaw", "1", FCVAR_ARCHIVE )

CreateConVar( "dredux_intro", "1", FCVAR_ARCHIVE )

-- DMG Mul
	
CreateConVar( "dredux_dmg_mul", "1", FCVAR_ARCHIVE )

-- Melee
	
CreateConVar( "dredux_dmg_melee", "15" )
CreateConVar( "dredux_dmg_fists", "20" )

-- Pistol
	
CreateConVar( "dredux_dmg_pistol", "10" )
CreateConVar( "dredux_dmg_pistol_charge_mul", "1" )
	
-- Shotgun
	
CreateConVar( "dredux_dmg_shotgun", "55" )

CreateConVar( "dredux_dmg_sgren_i", "25" )
CreateConVar( "dredux_dmg_sgren_sp", "60" )
CreateConVar( "dredux_dmg_sgren_cl", "10" )

CreateConVar( "dredux_dmg_sgren2_i", "25" )
CreateConVar( "dredux_dmg_sgren2_sp", "60" )
	
-- Super Shotgun
	
CreateConVar( "dredux_dmg_supershotgun", "160" )
	
-- Heavy AR
	
CreateConVar( "dredux_dmg_har", "12" )
CreateConVar( "dredux_dmg_har_scoped", "16" )

CreateConVar( "dredux_dmg_har_rocket_i", "15" )
CreateConVar( "dredux_dmg_har_rocket_sp", "15" )

CreateConVar( "dredux_dmg_har2", "15" )
CreateConVar( "dredux_dmg_har2_scoped", "75" )

CreateConVar( "dredux_dmg_har2_rocket_i", "5" )
CreateConVar( "dredux_dmg_har2_rocket_sp", "20" )
	
-- Chaingun
	
CreateConVar( "dredux_dmg_chaingun", "10" )
CreateConVar( "dredux_dmg_chaingun_inc", "11" )
CreateConVar( "dredux_dmg_chaingun_turret", "11" )

-- Plasma Rifle

CreateConVar( "dredux_dmg_plasma_i", "6" )
CreateConVar( "dredux_dmg_plasma_sp", "2" )

CreateConVar( "dredux_dmg_plasma_heatblast", "80" )

CreateConVar( "dredux_dmg_plasma_microwaveexplo", "150" )

CreateConVar( "dredux_dmg_plasma2_i", "8" )
CreateConVar( "dredux_dmg_plasma2_sp", "3" )

CreateConVar( "dredux_dmg_plasma2_microwave", "8" )

-- Gauss
	
CreateConVar( "dredux_dmg_gauss_i", "100" )
CreateConVar( "dredux_dmg_gauss2_i", "125" )
CreateConVar( "dredux_dmg_gauss_sp", "25" )

CreateConVar( "dredux_dmg_gauss_precision_base", "75" )
CreateConVar( "dredux_dmg_gauss_precision_add", "200" )

CreateConVar( "dredux_dmg_gauss_siege", "300" )
CreateConVar( "dredux_dmg_gauss_siege_ray", "100" )

CreateConVar( "dredux_dmg_gauss2_arbalest_i", "50" )
CreateConVar( "dredux_dmg_gauss2_arbalest_sp", "200" )

CreateConVar( "dredux_dmg_gauss2_destroyer1", "100" )
CreateConVar( "dredux_dmg_gauss2_destroyer2", "225" )
CreateConVar( "dredux_dmg_gauss2_destroyer3", "350" )

-- Rocket Launcher
	
CreateConVar( "dredux_dmg_rocket_i", "50" )
CreateConVar( "dredux_dmg_rocket_sp", "100" )

CreateConVar( "dredux_dmg_lockonrocket_i", "75" )
CreateConVar( "dredux_dmg_lockonrocket2_i", "125" )
	
-- BFG
	
CreateConVar( "dredux_dmg_bfg", "1200" )
CreateConVar( "dredux_dmg_bfg_rays", "50" ) -- Applied 5 times per second

CreateConVar( "dredux_bfg_restricted", "0", FCVAR_ARCHIVE )
CreateConVar( "dredux_bfg_damageplayers", "1", FCVAR_ARCHIVE )
CreateConVar( "dredux_bfg_rays_damageplayers", "0", FCVAR_ARCHIVE )
	
-- Unmaker
	
CreateConVar( "dredux_dmg_unmaker", "60" )
CreateConVar( "dredux_unmaker_restricted", "0", FCVAR_ARCHIVE )

--

CreateConVar( "dredux_chainsaw_pvp", "1", FCVAR_ARCHIVE )

-- MP Bolt Rifle
	
CreateConVar( "dredux_dmg_mp_burstrifle", "10" ) -- Pistol damage

--

--

hook.Add( "PlayerSpawn", "DOOM_GiveWeaponsOnSpawn", function( ply, transition )

	--if transition then return end
	
	timer.Simple( 0, function()
	
		ply:GiveAmmo( 1, "DOOM_BloodPunch", true )
		ply:GiveAmmo( 1, "DOOM_Grenade", true )
		ply:GiveAmmo( 1, "DOOM_FreezeGrenade", true )
		ply:GiveAmmo( 1, "DOOM_FlameBelch", true )
	
		if IsValid( ply ) then
			
			if !GetConVar( "dredux_keepeqondeath" ):GetBool() then
	
				ply:SetNW2Bool( "DOOM_BloodPunch", false )
				ply:SetNW2Bool( "DOOM_Grenade", false )
				ply:SetNW2Bool( "DOOM_FreezeGrenade", false )
				ply:SetNW2Bool( "DOOM_FlameBelch", false )
		
			end
		
			local wep = GetConVar( "dredux_startweapon" ):GetInt()
			
			if wep == 1 then
			
				ply:Give( "weapon_dredux_d2016_chainsaw" )
				ply:Give( "weapon_dredux_d2016_pistol" )
				ply:Give( "weapon_dredux_d2016_shotgun" )
				
				ply:SelectWeapon( "weapon_dredux_d2016_shotgun" )
				
			elseif wep == 2 then
			
				ply:Give( "weapon_dredux_d2016_chainsaw" )
				ply:Give( "weapon_dredux_d2016_pistol" )
				ply:Give( "weapon_dredux_d2016_shotgun" )
				ply:Give( "weapon_dredux_d2016_double_barrel" )
				ply:Give( "weapon_dredux_d2016_heavy_ar" )
				
				if GetConVar( "dredux_loadout_deplasma" ):GetBool() then
					ply:Give( "weapon_dredux_de_plasma" )
				else
					ply:Give( "weapon_dredux_d2016_plasma" )
				end
				
				ply:Give( "weapon_dredux_d2016_chaingun" )
				ply:Give( "weapon_dredux_d2016_rocketlauncher" )
				ply:Give( "weapon_dredux_d2016_gauss" )
				
				if !GetConVar( "dredux_loadout_nosuperweps" ):GetBool() then
					ply:Give( "weapon_dredux_d2016_bfg" )
				end
				
				ply:SelectWeapon( "weapon_dredux_d2016_shotgun" )
				
			elseif wep == 3 then
			
				ply:Give( "weapon_dredux_d2016_chainsaw" )
				ply:Give( "weapon_dredux_de_shotgun" )
				
				ply:SelectWeapon( "weapon_dredux_de_shotgun" )
				
			elseif wep == 4 then
			
				ply:Give( "weapon_dredux_d2016_chainsaw" )
				ply:Give( "weapon_dredux_de_shotgun" )
				ply:Give( "weapon_dredux_de_supershotgun" )
				ply:Give( "weapon_dredux_de_heavy_ar" )
				ply:Give( "weapon_dredux_de_plasma" )
				ply:Give( "weapon_dredux_de_rocketlauncher" )
				ply:Give( "weapon_dredux_de_chaingun" )
				ply:Give( "weapon_dredux_de_gauss" )
				
				if !GetConVar( "dredux_loadout_nosuperweps" ):GetBool() then
					ply:Give( "weapon_dredux_de_bfg" )
					ply:Give( "weapon_dredux_de_unmaker" )
				end
				
				ply:SelectWeapon( "weapon_dredux_de_shotgun" )
			
			end
		
			timer.Simple( 0, function()
				if IsValid( ply ) && wep ~= 0 && GetConVar( "dredux_loadout_nosandboxweps" ):GetBool() then
					ply:StripWeapon( "gmod_camera" )
					ply:StripWeapon( "gmod_tool" )
					ply:StripWeapon( "weapon_physgun" )
				end
				
			end )
			
		end
		
	end )
	
end )



----------------------------------------------------------------------------------------------------
-- INIT PARTICLES
----------------------------------------------------------------------------------------------------

game.AddAmmoType( {
	name = "DOOM_Crucible",
	dmgtype = DMG_SLASH,
	maxcarry = 3
	
} )

game.AddAmmoType( {
	name = "DOOM_Chainsaw",
	dmgtype = DMG_SLASH,
	maxcarry = 3
} )

game.AddAmmoType( {
	name = "DOOM_BFG",
	dmgtype = DMG_BLAST,
	maxcarry = 60
	
} )

game.AddAmmoType( {
	name = "DOOM_BloodPunch",
	dmgtype = DMG_BLAST,
	maxcarry = 1
	
} )

game.AddAmmoType( {
	name = "DOOM_Grenade",
	dmgtype = DMG_BLAST,
	maxcarry = 1
	
} )

game.AddAmmoType( {
	name = "DOOM_FreezeGrenade",
	dmgtype = DMG_BLAST,
	maxcarry = 1
	
} )

game.AddAmmoType( {
	name = "DOOM_FlameBelch",
	dmgtype = DMG_BLAST,
	maxcarry = 1
	
} )

----------------------------------------------------------------------------------------------------
-- INIT PARTICLES
----------------------------------------------------------------------------------------------------

game.AddParticles( "particles/doom_vfx_weapons.pcf" )

	-- PARTICLE PRECACHING

	PrecacheParticleSystem( "d_muzzleflash" )
	PrecacheParticleSystem( "d_pistol_muzzleflash" )
	
	-- PARTICLE PRECACHING END