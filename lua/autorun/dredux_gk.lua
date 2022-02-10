
CreateConVar( "dredux_loot_drops", "1", FCVAR_ARCHIVE )
CreateConVar( "dredux_freezebomb_hp", "1", FCVAR_ARCHIVE )


CreateConVar( "dredux_gk_drops", "1", FCVAR_ARCHIVE )

function DOOM_CreateGKDrops( victim, class, num )

	if num < 1 then return end

	for i = 1, num do
	
		local ent = ents.Create( class )
		ent:SetPos( victim:GetPos() + victim:OBBCenter() + VectorRand()*5 )
		ent:SetAngles( AngleRand() )
		ent:Spawn()
		ent:Activate()
			
		local phys = ent:GetPhysicsObject()
		if IsValid( phys ) then
			phys:SetVelocity( Vector( math.random( -100, 100 ), math.random( -100, 100 ), 150 ) )
		end
		
	end
	
end

----------------------------------------------------------------------------------------------------

local function DOOM_LootDrops( victim, attacker, inflictor )

	if !GetConVar( "dredux_loot_drops" ):GetBool() || !IsValid( attacker ) || !IsValid( inflictor ) then return end

	local armor_max = math.Clamp( victim:GetMaxHealth()/75, 2, 7 ) + math.random( 1 )

	if victim:IsOnFire() then
		DOOM_CreateGKDrops( victim, "doom_loot_armor", armor_max*1.5 )
	end
	
	local wep = attacker:IsPlayer() && attacker:GetActiveWeapon()
	--local bloodpunch = ( wep && wep:GetClass() == "weapon_dredux_d2016_hands" && wep:GetNW2Bool( "BloodPunch" ) )
	
	if ( wep && wep:GetClass() == "weapon_dredux_d2016_hands" && wep:GetNW2Bool( "BloodPunch" ) ) then
		DOOM_CreateGKDrops( victim, "doom_loot_hp", math.random( 3, 5 ) )
		
	elseif victim.DOOM_Freezed && GetConVar( "dredux_freezebomb_hp" ):GetBool() then
		DOOM_CreateGKDrops( victim, "doom_loot_hp", armor_max )
		
	elseif ( attacker:Health() < attacker:GetMaxHealth() * 0.5 ) then
		DOOM_CreateGKDrops( victim, "doom_loot_hp", math.random( 1, 2 ) )
		
	end

end

----------------------------------------------------------------------------------------------------

hook.Add( "OnNPCKilled", "DOOM_LootDrops", function( npc, attacker, inflictor )
	--print( attacker:GetClass() )
	DOOM_LootDrops( npc, attacker, inflictor )
end )

if CLIENT then


	local function DOOMWeapons_MenuGK( Panel )
	
		if game.SinglePlayer() || ( LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) then
	
			Panel:SetName( "DOOM Loot options" )
			
			Panel:AddControl( "CheckBox", { Label = "Enable Loot Drops?", Command = "dredux_loot_drops" } )
			Panel:AddControl( "CheckBox", { Label = "Freezed Enemies drop HP?", Command = "dredux_freezebomb_hp" } )
		
		end

	end
	

	hook.Add( "PopulateToolMenu", "DOOMWeapons_GloryKills_Menu", function()
		
		spawnmenu.AddToolMenuOption( "Utilities", "DOOM", "DOOM_GlorykillsLootOptions", "Loot Options", "", "", DOOMWeapons_MenuGK, {} )

	end )
	
end