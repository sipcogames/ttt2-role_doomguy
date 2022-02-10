
-- All credits go to Dragoteryx, he allowed me to steal his code ovo
-- I modified it a lot tho

ENT.Base = "base_gmodentity"
ENT.IsDOOMProjectile = true

-- Misc --
ENT.PrintName = "Projectile"
ENT.Category = ""
ENT.Models = {}
ENT.ModelScale = 1

-- Physics --
ENT.Gravity = true
ENT.Physgun = false
ENT.Gravgun = false

-- Contact --
ENT.OnContactDelay = 0.1
ENT.OnContactDelete = -1
ENT.OnContactDecals = {}

-- Sounds --
ENT.LoopSounds = {}
ENT.OnContactSounds = {}
ENT.OnRemoveSounds = {}

-- Effects --
ENT.AttachEffects = {}
ENT.OnContactEffects = {}
ENT.OnRemoveEffects = {}

ENT.Effect_Glow = Material( "particle/particle_glow_04.vmt" )

-- Misc --

local entMETA = FindMetaTable("Entity")

if SERVER then

  local old_GetVelocity = entMETA.GetVelocity
  function entMETA:GetVelocity()
    if self.IsDrGProjectile then
      local phys = self:GetPhysicsObject()
      if IsValid(phys) then
        return phys:GetVelocity()
      else return old_GetVelocity(self) end
    else return old_GetVelocity(self) end
  end

  local old_SetVelocity = entMETA.SetVelocity
  function entMETA:SetVelocity(velocity)
    if self.IsDrGProjectile then
      local phys = self:GetPhysicsObject()
      if IsValid(phys) then
        return phys:SetVelocity(velocity)
      else return old_SetVelocity(self, velocity) end
    else return old_SetVelocity(self, velocity) end
  end

end

-- Convars --

local ProjectileTickrate = 0.1

-- Handlers --

hook.Add("PhysgunPickup", "DrGBaseProjectilePhysgun", function(ply, ent)
  if ent.IsDOOMProjectile then return false end
end)

if SERVER then

  AddCSLuaFile()

  -- Init/Think --

  function ENT:SpawnFunction(ply, tr, class)
    if not tr.Hit then return end
    local pos = tr.HitPos + tr.HitNormal*16
    local ent = ents.Create(class)
    ent:SetOwner(ply)
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
	  return ent
  end

  function ENT:Initialize()
  
    if #self.Models > 0 then
      self:SetModel(self.Models[math.random(#self.Models)])
    else
      self:SetModel("models/props_junk/watermelon01.mdl")
      self:SetNoDraw(true)
    end
	
    self:SetModelScale(self.ModelScale)
  --  self:SetTrigger(true)
	
    -- sounds/effects --
    self:CallOnRemove("DrGBaseOnRemoveSoundsEffects", function(self)
      if #self.OnRemoveSounds > 0 then
        self:EmitSound(self.OnRemoveSounds[math.random(#self.OnRemoveSounds)])
      end
      if #self.OnRemoveEffects > 0 then
        ParticleEffect(self.OnRemoveEffects[math.random(#self.OnRemoveEffects)], self:GetPos(), self:GetAngles())
      end
    end)
    if #self.LoopSounds > 0 then
      self._DrGBaseLoopingSound = self:StartLoopingSound(self.LoopSounds[math.random(#self.LoopSounds)])
      self:CallOnRemove("DrGBaseStopLoopingSound", function(self)
        self:StopLoopingSound(self._DrGBaseLoopingSound)
      end)
    end
    if #self.AttachEffects > 0 then
      self:ParticleEffect(self.AttachEffects[math.random(#self.AttachEffects)])
    end
	
	self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
	
	local phys = self:GetPhysicsObject()
    if IsValid(phys) then
	  phys:SetMass( 1 )
      --phys:Wake()
	  phys:EnableDrag( false )
      phys:EnableGravity(tobool(self.Gravity))
    end
	
    -- custom code --
    self:_BaseInitialize()
    self:CustomInitialize()
    self._DrGBaseBaseThinkDelay = 0
    self._DrGBaseCustomThinkDelay = 0
	
  end
  
  function ENT:_BaseInitialize() end
  function ENT:CustomInitialize() end

  function ENT:Think()
    local delay = self:CustomThink() or 0
    local thinkdelay = CurTime() + delay
    self:NextThink( CurTime() + thinkdelay )
    return true
  end
  
  function ENT:_BaseThink() end
  function ENT:CustomThink() end

  -- Collisions --

  function ENT:PhysicsCollide(data)
  
    local ent = data.HitEntity
    if not IsValid(ent) and not ent:IsWorld() then return end
	
    if ent:IsWorld() and #self.OnContactDecals > 0 then
		util.Decal(self.OnContactDecals[math.random(#self.OnContactDecals)], data.HitPos+data.HitNormal, data.HitPos-data.HitNormal)
    end
	
    self:Contact(ent)
	
  end

  function ENT:Contact(ent)
  
	if not IsValid(ent) and not ent:IsWorld() then return end
  --  if string.find( ent:GetClass(), "trigger" ) then return end
	--if string.find( ent:GetClass(), "color_correction" ) then return end
	
	
    if self:OnContact(ent) ~= false then
	
      if #self.OnContactSounds > 0 then
        self:EmitSound(self.OnContactSounds[math.random(#self.OnContactSounds)])
      end
	  
      if #self.OnContactEffects > 0 then
        ParticleEffect(self.OnContactEffects[math.random(#self.OnContactEffects)], self:GetPos(), self:GetAngles())
      end
	  
      if self.OnContactDelete == 0 then
        self:Remove()
      elseif self.OnContactDelete > 0 then
        timer.Simple( self.OnContactDelete, function() if IsValid( self ) then self:Remove() end end )
      end
	  
    end
	
  end
  
  function ENT:OnContact() end

  -- Misc --

  function ENT:OnDealtDamage(ent, dmg)
    if dmg:IsDamageType(DMG_CRUSH) then return true end
  end
  
  function ENT:ScaleOutputDamage( convar )
	return GetConVar( convar ):GetInt() * GetConVar( "dredux_dmg_mul" ):GetFloat()
  end


  -- Helpers --

  function ENT:AimAt(target, speed, feet)
    return self:DrG_AimAt(target, speed, feet)
  end
  function ENT:ThrowAt(target, options, feet)
    return self:DrG_ThrowAt(target, options, feet)
  end

  function ENT:DealDamage(ent, value, type, force )
    if ent == self then return end
    local dmg = DamageInfo()
    dmg:SetDamage( value )
	dmg:SetMaxDamage( value*2 )
    dmg:SetDamageForce( force || self:GetVelocity() )
	if ent:IsNPC() && type then type = bit.bor( DMG_GENERIC, DMG_BLAST, type ) end
    dmg:SetDamageType( type || DMG_DIRECT )
    if IsValid(self:GetOwner()) then
      dmg:SetAttacker(self:GetOwner())
    else dmg:SetAttacker(self) end
    dmg:SetInflictor(self)
	dmg:SetDamagePosition( self:GetPos() )
    ent:TakeDamageInfo(dmg)
  end
  
  function ENT:RadiusDamage(damage, type, range, filter)
    local owner = self:GetOwner()
    if not isfunction(filter) then filter = function(ent)
      if ent == owner then return false end
      if not IsValid(owner) or not owner.IsDrGNextbot then return true end
      return not owner:IsAlly(ent)
    end end
    for i, ent in ipairs(ents.FindInSphere(self:GetPos(), range)) do
      if not IsValid(ent) then continue end
      if ent == self then continue end
      if not filter(ent) then continue end
	  if ent == self:GetOwner() then damage = damage*0.25 end
      self:DealDamage(ent, damage*math.Clamp((range-self:GetPos():Distance(ent:GetPos()))/range, 0, 1), type)
    end
  end

  function ENT:Explosion(damage, range, filter)
    local explosion = ents.Create("env_explosion")
    if IsValid(explosion) then
      explosion:Spawn()
      explosion:SetPos(self:GetPos())
      explosion:SetKeyValue("iMagnitude", 0)
      explosion:SetKeyValue("iRadiusOverride", 0)
      explosion:Fire("Explode", 0, 0)
    else
      local fx = EffectData()
      fx:SetOrigin(self:GetPos())
      util.Effect("Explosion", fx)
    end
    self:RadiusDamage(damage, DMG_BLAST, range, filter)
  end
  
	function ENT:DynamicLight(color, radius, brightness, style, attachment)
		return self:DrG_DynamicLight(color, radius, brightness, style, attachment)
	end

 function ENT:DrG_DynamicLight(color, radius, brightness, style, attachment)
    if color == nil then color = Color(255, 255, 255) end
    if not isnumber(radius) then radius = 1000 end
    radius = math.Clamp(radius, 0, math.huge)
    if not isnumber(brightness) then brightness = 1 end
    brightness = math.Clamp(brightness, 0, math.huge)
    local light = ents.Create("light_dynamic")
  	light:SetKeyValue("brightness", tostring(brightness))
  	light:SetKeyValue("distance", tostring(radius))
    if isstring(style) then
      light:SetKeyValue("style", tostring(style))
    end
    light:Fire("Color", tostring(color.r).." "..tostring(color.g).." "..tostring(color.b))
  	light:SetLocalPos(self:GetPos())
  	light:SetParent(self)
    if isstring(attachment) then
      light:Fire("setparentattachment", attachment)
    end
  	light:Spawn()
  	light:Activate()
  	light:Fire("TurnOn", "", 0)
  	self:DeleteOnRemove(light)
    return light
  end

else

  -- Effects --

  function ENT:DrG_DynamicLight(color, radius, brightness, style, attachment)
    if color == nil then color = Color(255, 255, 255) end
    if not isnumber(radius) then radius = 1000 end
    radius = math.Clamp(radius, 0, math.huge)
    if not isnumber(brightness) then brightness = 1 end
    brightness = math.Clamp(brightness, 0, math.huge)
    local light = DynamicLight(self:EntIndex())
    light.r = color.r
    light.g = color.g
    light.b = color.b
    light.size = radius
    light.brightness = brightness
    light.style = style
    light.dieTime = CurTime() + 1
    light.decay = 100000
    if attachment then
      if isstring(attachment) then
        attachment = self:LookupAttachment(attachment)
      end
      if isnumber(attachment) and attachment > 0 then
        light.pos = self:GetAttachment(attachment).Pos
      else light.pos = self:GetPos() end
    else light.pos = self:GetPos() end
    return light
  end

  function ENT:Initialize()
    self._DrGBaseBaseThinkDelay = 0
    self._DrGBaseCustomThinkDelay = 0
    self:_BaseInitialize()
    self:CustomInitialize()
	
	if !game.SinglePlayer() && CLIENT then 
		--self:SetPredictable( true )
	end
	
  end
  
  function ENT:_BaseInitialize() end
  function ENT:CustomInitialize() end

  function ENT:Think()
    if CurTime() > self._DrGBaseCustomThinkDelay then
      local delay = self:CustomThink() or 0
      self._DrGBaseCustomThinkDelay = CurTime() + delay
    end
	self:NextThink( CurTime() )
  end
  
  function ENT:_BaseThink() end
  function ENT:CustomThink() end

  function ENT:Draw()
    self:DrawModel()
    self:_BaseDraw()
    self:CustomDraw()
  end
  function ENT:_BaseDraw() end
  function ENT:CustomDraw() end

	function ENT:DynamicLight(color, radius, brightness, style, attachment)
		return self:DrG_DynamicLight(color, radius, brightness, style, attachment )
	end

end