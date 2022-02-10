--ConVar syncing
CreateConVar("ttt2_doomguy_armor", "50", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_doomguy_tracker_mode", "2", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_doomguy_force_model", "1", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_doomguy_max_health", "200", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_doomguy_intro_music", "0", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_doomguy_lifesteal", "0.25", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_doomguy_shotgun_base_dmg", "5", {FCVAR_ARCHIVE, FCVAR_NOTFIY})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicDoomGuyCVars", function(tbl)
	tbl[ROLE_DOOMGUY] = tbl[ROLE_DOOMGUY] or {}

	table.insert(tbl[ROLE_DOOMGUY], {
		cvar = "ttt2_doomguy_armor",
		slider = true,
		min = 0,
		max = 100,
		decimal = 0,
		desc = "ttt2_doomguy_armor [0..100] (Def: 50)"
	})

	table.insert(tbl[ROLE_DOOMGUY], {
		cvar = "ttt2_doomguy_tracker_mode",
		combobox = true,
		desc = "ttt2_doomguy_tracker_mode (Def: 2)",
		choices = {
			"0 - Doom Slayer does not spawn with a tracking device",
			"1 - Doom Slayer spawns with a radar",
			"2 - Doom Slayer spawns with a tracker"
		},
		numStart = 0
	})

	table.insert(tbl[ROLE_DOOMGUY], {
    cvar = "ttt2_doomguy_force_model",
    checkbox = true,
    desc = "ttt2_doomguy_force_model (Def. 1)"
    })

    table.insert(tbl[ROLE_DOOMGUY], {
		cvar = "ttt2_doomguy_max_health",
		slider = true,
		min = 1,
		max = 300,
		decimal = 0,
		desc = "ttt2_doomguy_max_health [1..300] (Def: 200)"
	})

	table.insert(tbl[ROLE_DOOMGUY], {
		cvar = "ttt2_doomguy_intro_music",
		combobox = true,
		desc = "ttt2_doomguy_intro_music (Def: 0)",
		choices = {
			"0 - Semi Short intro (40 sec)",
			"1 - Full Game theme (12min)",
			"2 - No Music Intro"
		},
		numStart = 0
	})

	table.insert(tbl[ROLE_DOOMGUY], {
		cvar = "ttt2_doomguy_lifesteal",
		slider = true,
		min = 0,
		max = 1,
		decimal = 2,
		desc = "ttt2_doomguy_lifesteal [0..1] (Def: 0.25)"
	})

	table.insert(tbl[ROLE_DOOMGUY], {
		cvar = "ttt2_doomguy_shotgun_base_dmg",
		slider = true,
		min = 1,
		max = 100,
		decimal = 0,
		desc = "ttt2_doomguy_shotgun_base_dmg [1..100] (Def: 5)"
	})
end)
