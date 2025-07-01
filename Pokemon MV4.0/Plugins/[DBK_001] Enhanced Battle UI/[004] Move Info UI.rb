#===============================================================================
# Move Info UI
#===============================================================================
class Battle::Scene  
  #-----------------------------------------------------------------------------
  # Toggles the visibility of the Move Info UI.
  #-----------------------------------------------------------------------------
  def pbToggleMoveInfo(*args)
    return if pbInSafari?
    pbHideInfoUI if @enhancedUIToggle != :move
    @enhancedUIToggle = (@enhancedUIToggle.nil?) ? :move : nil
    (@enhancedUIToggle) ? pbSEPlay("GUI party switch") : pbPlayCloseMenuSE
    @sprites["enhancedUI"].visible = !@enhancedUIToggle.nil?
    (@sprites["enhancedUI"].visible) ? pbHideUIPrompt : pbRefreshUIPrompt
    pbUpdateTargetIcons
    pbUpdateMoveInfoWindow(*args)
  end

  #-----------------------------------------------------------------------------
  # Updates icon sprites to be used for the Move Info UI.
  #-----------------------------------------------------------------------------
  def pbUpdateTargetIcons
    idx = 0
    @battle.allBattlers.each do |b|
      if b && !b.fainted? && b.index.odd?
        @sprites["info_icon#{b.index}"].pokemon = b.displayPokemon
        @sprites["info_icon#{b.index}"].visible = @enhancedUIToggle == :move
        @sprites["info_icon#{b.index}"].x = Graphics.width - 32 - (idx * 64)
        @sprites["info_icon#{b.index}"].y = 68
        if b.dynamax?
          @sprites["info_icon#{b.index}"].set_dynamax_icon_pattern
        elsif b.tera?
          @sprites["info_icon#{b.index}"].set_tera_icon_pattern
        else
          @sprites["info_icon#{b.index}"].zoom_x = 1
          @sprites["info_icon#{b.index}"].zoom_y = 1
          @sprites["info_icon#{b.index}"].pattern = nil
        end
        idx += 1
      else
        @sprites["info_icon#{b.index}"].visible = false
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Draws the Move Info UI.
  #-----------------------------------------------------------------------------
  def pbUpdateMoveInfoWindow(battler, specialAction, cw)
    @enhancedUIOverlay.clear
    return if @enhancedUIToggle != :move
    xpos = 0
    ypos = 94
    move = battler.moves[cw.index]
    if battler.dynamax? || specialAction == :dynamax && cw.mode == 2
      move = move.convert_dynamax_move(battler, @battle)
    end
    powBase   = accBase   = priBase   = effBase   = BASE_LIGHT
    powShadow = accShadow = priShadow = effShadow = SHADOW_LIGHT
    basePower = calcPower = power = move.power
    category = move.category
    type = move.pbCalcType(battler)
    terastal = battler.tera? || (specialAction == :tera && cw.teraType > 0)
    #---------------------------------------------------------------------------
    # Gets move type and category (for display purposes).
    case move.function_code
    when "CategoryDependsOnHigherDamageTera",
         "TerapagosCategoryDependsOnHigherDamage"
      if terastal
        case move.function_code
        when "CategoryDependsOnHigherDamageTera"
          type = battler.tera_type
          basePower = calcPower = power = 100
        when "TerapagosCategoryDependsOnHigherDamage"
          type = :STELLAR if battler.isSpecies?(:TERAPAGOS)
        end
        realAtk, realSpAtk = battler.getOffensiveStats
        category = (realAtk > realSpAtk) ? 0 : 1
      else
        type = move.type
        category = move.calcCategory
      end
    when "CategoryDependsOnHigherDamagePoisonTarget", 
         "CategoryDependsOnHigherDamageIgnoreTargetAbility"
      move.pbOnStartUse(battler, [battler.pbDirectOpposing])
      category = move.calcCategory
    end
    #---------------------------------------------------------------------------
    # Draws images.
    typenumber = GameData::Type.get(type).icon_position
    bgnumber = (Settings::USE_MOVE_TYPE_BACKGROUNDS) ? typenumber + 1 : 0
    imagePos = [
      [@path + "move_bg",      xpos,       ypos,     0, bgnumber * 188, 640, 188],
      ["Graphics/UI/types",    xpos + 282 + 50-22-36, ypos + 6, 0, typenumber * 28, 64, 28],
      ["Graphics/UI/category", xpos + 350+90-34, ypos + 6, 0, category * 28, 64, 28]
    ]
    pbDrawMoveFlagIcons(xpos, ypos, move, imagePos)
    pbDrawTypeEffectiveness(xpos, ypos, move, type, imagePos)
    pbDrawImagePositions(@enhancedUIOverlay, imagePos)
    #---------------------------------------------------------------------------
    # Move damage calculations (for display purposes).
    if move.damagingMove?
      if terastal
        if battler.typeTeraBoosted?(type, true)
          bonus = (battler.tera_type == :STELLAR) ? 1.2 : 1.5
          stab = (battler.types.include?(type)) ? 2 : bonus
        else
          stab = (battler.types.include?(type)) ? 1.5 : 1
        end
      else
        stab = (battler.pbHasType?(type)) ? 1.5 : 1
      end
      stab = 1 if defined?(move.pbFixedDamage(battler, battler.pbDirectOpposing))
      hidePower = false
      case move.function_code
      when "ThrowUserItemAtTarget"                     # Fling
        hidePower = true if !battler.item
      when "TypeAndPowerDependOnUserBerry"             # Natural Gift
        hidePower = true if !battler.item || !battler.item.is_berry?
      when "PursueSwitchingFoe",                       # Pursuit
           "RemoveTargetItem",                         # Knock Off
           "HitOncePerUserTeamMember",                 # Beat Up
           "DoublePowerIfTargetActed",                 # Payback
           "DoublePowerIfTargetNotActed",              # Bolt Beak, Fishious Rend
           "PowerHigherWithTargetHP",                  # Crush Grip, Wring Out
           "PowerHigherWithTargetHP100PowerRange",     # Hard Press
           "HitThreeTimesPowersUpWithEachHit",         # Triple Kick
           "PowerHigherWithTargetWeight",              # Low Kick, Grass Knot
           "PowerHigherWithUserFasterThanTarget",      # Electro Ball
           "PowerHigherWithTargetFasterThanUser",      # Gyro Ball
           "FixedDamageUserLevelRandom",               # Psywave
           "RandomlyDamageOrHealTarget",               # Present
           "RandomlyDealsDoubleDamage",                # Fickle Beam
           "RandomPowerDoublePowerIfTargetUnderground" # Magnitude
        hidePower = true if calcPower == 1
      end
      if !hidePower
        calcPower = move.pbBaseDamage(basePower, battler, battler.pbDirectOpposing)
        calcPower = move.pbModifyDamage(calcPower, battler, battler.pbDirectOpposing)
        calcPower = move.pbBaseDamageTera(calcPower, battler, type, true) if terastal
      end
      hidePower = true if calcPower == 1
      powerDiff = (move.function_code == "PowerHigherWithUserHP") ? calcPower - basePower : basePower - calcPower
      calcPower *= stab
      power = (calcPower >= powerDiff) ? calcPower : basePower * stab
    end
    #---------------------------------------------------------------------------
    # Final move attribute calculations.
    acc = move.accuracy
    pri = move.priority
    case move.function_code
    when "ParalyzeFlinchTarget", "BurnFlinchTarget", "FreezeFlinchTarget"
      chance = 10
    when "LowerTargetDefense1FlinchTarget"
      chance = 50
    else
      chance = move.addlEffect
    end
    baseChance = chance
    showTera = terastal && battler.typeTeraBoosted?(type, true)
    bonus, power, acc, pri, chance = pbGetFinalModifier(
      battler, move, type, basePower, power, acc, pri, chance, showTera)
    calcPower = power if power > basePower
    if power > 1
      if calcPower > basePower
        powBase, powShadow = BASE_RAISED, SHADOW_RAISED
      elsif power < (basePower * stab).floor
        powBase, powShadow = BASE_LOWERED, SHADOW_LOWERED
      end
    end
    if acc > 0
      if acc > move.accuracy
        accBase, accShadow = BASE_RAISED, SHADOW_RAISED
      elsif acc < move.accuracy
        accBase, accShadow = BASE_LOWERED, SHADOW_LOWERED
      end
    end
    if pri != 0
      if pri > move.priority
        priBase, priShadow = BASE_RAISED, SHADOW_RAISED
      elsif pri < move.priority
        priBase, priShadow = BASE_LOWERED, SHADOW_LOWERED
      end
    end
    if chance > 0
      if chance > baseChance
        effBase, effShadow = BASE_RAISED, SHADOW_RAISED
      elsif chance < baseChance
        effBase, effShadow = BASE_LOWERED, SHADOW_LOWERED
      end
    end
    #---------------------------------------------------------------------------
    # Draws text.
    textPos = []
    displayPower    = (power  == 0) ? "---" : (hidePower) ? "???" : power.ceil.to_s
    displayAccuracy = (acc    == 0) ? "---" : acc.ceil.to_s
    displayPriority = (pri    == 0) ? "---" : (pri > 0) ? "+" + pri.to_s : pri.to_s
    displayChance   = (chance == 0) ? "---" : chance.ceil.to_s + "%"
    textPos.push(
      [move.name,       xpos + 10,  ypos + 12, :left,   BASE_LIGHT, SHADOW_LIGHT],
      [_INTL("Poder:"),    xpos + 256 + 78 - 14 - 42-14, ypos + 40, :left,   BASE_LIGHT, SHADOW_LIGHT],
      [displayPower,    xpos + 309+ 78 - 42-4-8, ypos + 40, :center, powBase,    powShadow],
      [_INTL("Precisión:"),    xpos + 348 + 90 -55, ypos + 40, :left,   BASE_LIGHT, SHADOW_LIGHT],
      [displayAccuracy, xpos + 401+ 90 + 44-58, ypos + 40, :center, accBase,    accShadow],
      [_INTL("Prioridad:"),    xpos + 442 + 108-30, ypos + 40, :left,   BASE_LIGHT, SHADOW_LIGHT],
      [displayPriority, xpos + 484+ 120 - 62 + 72, ypos + 40, :center, priBase,    priShadow],
      [_INTL("Efecto:"),    xpos + 442 + 108-30, ypos + 12, :left,   BASE_LIGHT, SHADOW_LIGHT],
      [displayChance,   xpos + 484 + 122, ypos + 12, :center, effBase,    effShadow]
    )
    textPos.push([bonus[0], xpos + 8, ypos + 132, :left, bonus[1], bonus[2]]) if bonus
    pbDrawTextPositions(@enhancedUIOverlay, textPos)
    drawTextEx(@enhancedUIOverlay, xpos + 8, ypos + 74, Graphics.width - 12, 2, 
      GameData::Move.get(move.id).description, BASE_LIGHT, SHADOW_LIGHT)
  end
  
  #-----------------------------------------------------------------------------
  # Draws the move flag icons for each move in the Move Info UI.
  #-----------------------------------------------------------------------------
  def pbDrawMoveFlagIcons(xpos, ypos, move, imagePos)
    flagX = xpos + 6
    flagY = ypos + 32+2
    icons = 0
    if defined?(move.zMove?) && move.zMove?
      imagePos.push([@path + "move_flags", flagX + (icons * 26), flagY, 0 * 26, 0, 26, 28])
      icons += 1
    elsif defined?(move.dynamaxMove?) && move.dynamaxMove?
      imagePos.push([@path + "move_flags", flagX + (icons * 26), flagY, 1 * 26, 0, 26, 28])
      icons += 1
    end
    if GameData::Target.get(move.target).targets_foe
      if !move.flags.include?("CanProtect")
        imagePos.push([@path + "move_flags", flagX + (icons * 26), flagY, 2 * 26, 0, 26, 28])
        icons += 1
      end
      if !move.flags.include?("CanMirrorMove")
        imagePos.push([@path + "move_flags", flagX + (icons * 26), flagY, 3 * 26, 0, 26, 28])
        icons += 1
      end
    end
    move.flags.each do |flag|
      idx = -1
      case flag
      when "Contact"          then idx = 4
      when "TramplesMinimize" then idx = 5
      when "ElectrocuteUser"  then idx = 7
      when "ThawsUser"        then idx = 8
      when "Sound"            then idx = 9
      when "Punching"         then idx = 10
      when "Biting"           then idx = 11
      when "Bomb"             then idx = 12
      when "Pulse"            then idx = 13
      when "Powder"           then idx = 14
      when "Dance"            then idx = 15
      when "Slicing"          then idx = 16
      when "Wind"             then idx = 17
      end
      idx = 6 if flag.include?("HighCriticalHitRate")
      next if idx < 0
      imagePos.push([@path + "move_flags", flagX + (icons * 26), flagY, idx * 26, 0, 26, 28])
      icons += 1
    end
  end
  
  #-----------------------------------------------------------------------------
  # Draws the type effectiveness display for each opponent in the Move Info UI.
  #-----------------------------------------------------------------------------
  def pbDrawTypeEffectiveness(xpos, ypos, move, type, imagePos)
    idx = 0
    @battle.allBattlers.each do |b|
      next if b.index.even?
      if b && !b.fainted? && move.category < 2
        poke = b.displayPokemon
        unknown_species = $player.pokedex.battled_count(poke.species) == 0 && !$player.pokedex.owned?(poke.species)
        unknown_species = false if Settings::SHOW_TYPE_EFFECTIVENESS_FOR_NEW_SPECIES
        unknown_species = true if b.celestial?
        value = Effectiveness.calculate(type, *b.pbTypes(true))
        if unknown_species                             then effct = 0
        elsif b.tera? && type == :STELLAR              then effct = 3
        elsif Effectiveness.ineffective?(value)        then effct = 1
        elsif Effectiveness.not_very_effective?(value) then effct = 2
        elsif Effectiveness.super_effective?(value)    then effct = 3
        else effct = 4
        end
        imagePos.push([@path + "move_effectiveness", Graphics.width - 64 - (idx * 64), ypos - 76, effct * 64, 0, 64, 76])
        @sprites["info_icon#{b.index}"].visible = true
      else
        @sprites["info_icon#{b.index}"].visible = false
      end
      idx += 1
    end
  end
  
  #-----------------------------------------------------------------------------
  # Applies final move attribute modifiers and any additional bonus text.
  #-----------------------------------------------------------------------------
  def pbGetFinalModifier(battler, move, type, baseDmg, power, acc, pri, chance, showTera)
    bonus = nil
    #---------------------------------------------------------------------------
    # Bonus text and modifiers for ability changes to move.
    #---------------------------------------------------------------------------
    if battler.abilityActive?
      target = (@battle.pbOpposingBattlerCount == 1) ? battler.pbDirectOpposing(true) : nil
      5.times do |i|
        break if bonus
        case i
        #-----------------------------------------------------------------------
        when 0 # Abilities that change move type.
          next if type == move.type
          newType = Battle::AbilityEffects.triggerModifyMoveBaseType(battler.ability, battler, move, move.type)
          next if newType != type
          bonus = [_INTL("Tipo cambiado por la habilidad {1}.", battler.abilityName), BASE_RAISED, SHADOW_RAISED]
          power *= 1.2 if move.powerBoost
          move.powerBoost = false
        #-----------------------------------------------------------------------
        when 1 # Abilities that alter base power.
          next if power == 0
          next if battler.hasActiveAbility?(:ANALYTIC)
          next if !target && battler.hasActiveAbility?(:RIVALRY)
          multipliers = {
            :power_multiplier        => 1.0,
            :attack_multiplier       => 1.0,
            :defense_multiplier      => 1.0,
            :final_damage_multiplier => 1.0
          }
          Battle::AbilityEffects.triggerDamageCalcFromUser(
            battler.ability, battler, (target || battler), move, multipliers, baseDmg, type
          )
          oldPower = power
          power *= multipliers[:power_multiplier]
          if power > oldPower
            bonus = [_INTL("Poder potenciado por la habilidad {1}.", battler.abilityName), BASE_RAISED, SHADOW_RAISED]
          elsif power < oldPower
            bonus = [_INTL("Poder debilitado por la habilidad {1}.", battler.abilityName), BASE_LOWERED, SHADOW_LOWERED]
          end
        #-----------------------------------------------------------------------
        when 2 # Abilities that alter accuracy.
          next if acc == 0
          modifiers = {
            :base_accuracy           => acc,
            :accuracy_stage          => 0,
            :evasion_stage           => 0,
            :accuracy_multiplier     => 1.0,
            :evasion_multiplier      => 1.0
          }
          Battle::AbilityEffects.triggerAccuracyCalcFromUser(
            battler.ability, modifiers, battler, (target || battler), move, type
          )
          oldAcc = acc
          acc = [modifiers[:base_accuracy] * modifiers[:accuracy_multiplier], 100].min
          if acc > oldAcc || acc == 0
            bonus = [_INTL("Precisión aumentada por la habilidad {1}.", battler.abilityName), BASE_RAISED, SHADOW_RAISED]
          elsif acc < oldAcc
            bonus = [_INTL("Precisión disminuida por la habilidad {1}.", battler.abilityName), BASE_LOWERED, SHADOW_LOWERED]
          end
        #-----------------------------------------------------------------------
        when 3 # Abilities that alter priority.
          oldPri = pri
          pri = Battle::AbilityEffects.triggerPriorityChange(battler.ability, battler, move, pri)
          if pri > oldPri
            bonus = [_INTL("Prioridad aumentada por la habilidad {1}.", battler.abilityName), BASE_RAISED, SHADOW_RAISED]
          elsif pri < oldPri
            bonus = [_INTL("Prioridad disminuida por la habilidad {1}.", battler.abilityName), BASE_LOWERED, SHADOW_LOWERED]
          end
        #-----------------------------------------------------------------------
        when 4 # Abilities that boost additional effect chance.
          next if power == 0 || [0, 100].include?(chance) || battler.ability_id != :SERENEGRACE
          chance = [chance * 2, 100].min
          bonus = [_INTL("AUmento de efectos secundarios por la habilidad {1}.", battler.abilityName), BASE_RAISED, SHADOW_RAISED]
        end
      end
    end
    #---------------------------------------------------------------------------
    # Special note for Mega Launcher + Heal Pulse.
    #---------------------------------------------------------------------------
    if battler.hasActiveAbility?(:MEGALAUNCHER) && move.healingMove? && move.pulseMove?
      bonus = [_INTL("Curación aumentada por la habilidad {1}.", battler.abilityName), BASE_RAISED, SHADOW_RAISED]
    end
    #---------------------------------------------------------------------------
    # Bonus text for moves that utilize special battle mechanics.
    #---------------------------------------------------------------------------
    if showTera && move.damagingMove?
	    bonus = [_INTL("Poder aumentado por la Teracristalización."), BASE_RAISED, SHADOW_RAISED]
    elsif defined?(move.zMove?) && move.zMove? && move.has_zpower?
      effect, stage = move.get_zpower_effect
      case effect
      when "HealUser"    then text = _INTL("Poder Z: Restaura completamente los PS del usuario.")
      when "HealSwitch"  then text = _INTL("Poder Z: Restaura completamente los PS del Pokémon que entra al combate.")
      when "CriticalHit" then text = _INTL("Poder Z: Sube la probabilidad de ataques críticos del usuario.")
      when "ResetStats"  then text = _INTL("Poder Z: Reinicia las características reducidas del usuario.")
      when "FollowMe"    then text = _INTL("Poder Z: El usuario se vuelve el centro de atención.")
      else
        if stage
          stat = (effect == "AllStats") ? "stats" : GameData::Stat.get(effect.to_sym).name
          case stage
          when "3" then text = _INTL("Poder Z: Aumentó drásticamente su {1}.", stat)
          when "2" then text = _INTL("Poder Z: Aumentó drásticamente su {1}.", stat)
          else          text = _INTL("Poder Z: Aumentó su {1}.", stat)
          end
        end
      end
      bonus = [text, BASE_RAISED, SHADOW_RAISED] if text
    end
    return bonus, power, acc, pri, chance
  end
end