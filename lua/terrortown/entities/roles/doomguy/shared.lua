if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_dg.vmt")
end

roles.InitCustomTeam("doomslayer", {
		icon = "vgui/ttt/dynamic/roles/icon_dg",
		color = Color(156, 26, 0, 255)
})

-- Make sure sound/model is precached
function ROLE:Precache()
	util.PrecacheSound("ttt2/doomguy/doomguy_short.mp3")
	util.PrecacheSound("ttt2/doomguy/doomguy_long.mp3")
	util.PrecacheModel("models/pechenko_121/doomslayer.mdl")
end

DG = {}

DG.model = util.IsValidModel("models/pechenko_121/doomslayer.mdl") and Model("models/pechenko_121/doomslayer.mdl") or Model("models/player/kleiner.mdl")

function ROLE:PreInitialize()
	self.color = Color(156, 26, 0, 255)

	self.abbr = "dg"
	self.score.killsMultiplier = 8
	self.score.teamKillsMultiplier = -8
	self.score.bodyFoundMuliplier = 3
	self.unknownTeam = true

	self.defaultTeam = TEAM_DOOMSLAYER
	self.defaultEquipment = SPECIAL_EQUIPMENT
	self.networkRoles = {JESTER}

	self.isOmniscientRole = true
	self.isPublicRole = true

	self.conVarData = {
		pct = 0.13,
		maximum = 1,
		minPlayers = 8,
		credits = 1,
		creditsAwardDeadEnable = 0,
		creditsAwardKillEnable = 0,
		togglable = true,
		shopFallback = SHOP_DISABLED
	}
end

if SERVER then
	--CONSTANTS
	-- Enum for tracker mode
	local TRACKER_MODE = {NONE = 0, RADAR = 1, TRACKER = 2}

	-- Give Loadout on respawn and rolechange
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		
		-- Give Doom Weapons & Ammo
		ply:StripWeapons()
		ply:GiveEquipmentWeapon("weapon_dredux_de_supershotgun")
		ply:GiveAmmo(999,"Buckshot",true) --give lots of super shotgun ammo

		-- Set Tracker Mode
		if GetConVar("ttt2_doomguy_tracker_mode"):GetInt() == TRACKER_MODE.RADAR then
			ply:GiveEquipmentItem("item_ttt_radar")
		elseif GetConVar("ttt2_doomguy_tracker_mode"):GetInt() == TRACKER_MODE.TRACKER then
			ply:GiveEquipmentItem("item_ttt_tracker")
		end

		-- Set Armor and HP
		ply:GiveArmor(GetConVar("ttt2_doomguy_armor"):GetInt())
		ply:SetHealth(GetConVar("ttt2_doomguy_max_health"):GetInt())
		ply:SetMaxHealth(GetConVar("ttt2_doomguy_max_health"):GetInt())

		-- emit doomslayer sounds
		if(GetConVar("ttt2_doomguy_intro_music"):GetInt() == 0) then --short music
			ply:EmitSound("ttt2/doomguy/doomguy_short.mp3",100)
		elseif(GetConVar("ttt2_doomguy_intro_music"):GetInt() == 1) then --long music
			ply:EmitSound("ttt2/doomguy/doomguy_long.mp3",100)
		else 
			--no sound
		end
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)

		-- Remove Doom Weps
		ply:StripWeapon("weapon_dredux_de_supershotgun")

		-- Reset Tracker
		if GetConVar("ttt2_doomguy_tracker_mode"):GetInt() == TRACKER_MODE.RADAR then
			ply:RemoveEquipmentItem("item_ttt_radar")
		elseif GetConVar("ttt2_doomguy_tracker_mode"):GetInt() == TRACKER_MODE.TRACKER then
			ply:RemoveEquipmentItem("item_ttt_tracker")
		end

		--Reset Armor and Health
		ply:RemoveArmor(GetConVar("ttt2_doomguy_armor"):GetInt())
		ply:SetHealth(100)
		ply:SetMaxHealth(100)

		-- stop doomslayer sounds
		if(GetConVar("ttt2_doomguy_intro_music"):GetInt() == 0) then --short music
			ply:StopSound("ttt2/doomguy/doomguy_short.mp3")
		elseif(GetConVar("ttt2_doomguy_intro_music"):GetInt() == 1) then --long music
			ply:StopSound("ttt2/doomguy/doomguy_long.mp3")
		else 
			--no sound
		end
	end

	hook.Add("TTT2UpdateSubrole", "UpdateDoomguyRoleSelect", function(ply, oldSubrole, newSubrole)
		if GetConVar("ttt2_doomguy_force_model"):GetBool() then
			if newSubrole == ROLE_DOOMGUY then
				ply:SetSubRoleModel(DG.model)
			elseif oldSubrole == ROLE_DOOMGUY then
				ply:SetSubRoleModel(nil)
			end
		end
	end)

	hook.Add("PlayerTakeDamage","DoomguyLifesteal", function(victim, infl, attacker, amount, dmginfo)

		if (not attacker:IsPlayer()) then return end --skip if attacker is not a player
    
    if(attacker:GetSubRole() == ROLE_DOOMGUY and victim:Alive() and victim:IsPlayer() and GetRoundState() == ROUND_ACTIVE) then

      local lifesteal = GetConVar("ttt2_doomguy_lifesteal"):GetFloat() or 0.25
      local healAmt = amount * lifesteal
      local DGHealth = attacker:Health()
      local DGMax = attacker:GetMaxHealth()
      local NewHP = DGHealth + healAmt

      if ((DGHealth+healAmt) >= DGMax) then
      	attacker:SetHealth(DGMax)
      else
      	attacker:SetHealth(NewHP)
      end
    end
  end)
end

if CLIENT then
  function ROLE:AddToSettingsMenu(parent)
    local form = vgui.CreateTTT2Form(parent, "header_roles_additional")

    form:MakeSlider({
      serverConvar = "ttt2_doomguy_armor",
      label = "ttt2_doomguy_armor",
      min = 0,
      max = 100,
      decimal = 0
    })

    form:MakeComboBox({
    	serverConvar = "ttt2_doomguy_tracker_mode",
    	label = "ttt2_doomguy_tracker_mode (Use ULX or Console)",
    	choices = {
				"0 - Doom Guy does not spawn with a tracking device",
				"1 - Doom Guy spawns with a radar",
				"2 - Doom Guy spawns with a tracker"
			},
			numStart = 0
    })

    form:MakeCheckBox({
      serverConvar = "ttt2_doomguy_force_model",
      label = "ttt2_doomguy_force_model"
    })

    form:MakeSlider({
      serverConvar = "ttt2_doomguy_max_health",
      label = "ttt2_doomguy_max_health",
      min = 1,
      max = 300,
      decimal = 0
    })

    form:MakeComboBox({
    	serverConvar = "ttt2_doomguy_intro_music",
    	label = "ttt2_doomguy_intro_music (Use ULX or Console)",
    	choices = {
				"0 - Short Intro Theme (40sec)",
				"1 - Game Theme Music (12min)",
				"2 - No Music"
			},
			numStart = 0
    })

    form:MakeSlider({
      serverConvar = "ttt2_doomguy_lifesteal",
      label = "ttt2_doomguy_lifesteal",
      min = 0,
      max = 1,
      decimal = 2
    })

    form:MakeSlider({
      serverConvar = "ttt2_doomguy_shotgun_base_dmg",
      label = "ttt2_doomguy_shotgun_base_dmg",
      min = 1,
      max = 100,
      decimal = 0
    })

  end
end
