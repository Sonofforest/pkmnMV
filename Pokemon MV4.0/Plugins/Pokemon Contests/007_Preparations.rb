#====================================================================================
#  DO NOT MAKE EDITS HERE
#====================================================================================

#====================================================================================
#  Main Command
#====================================================================================
def pbPokemonContest(rank: nil, category: nil, pokemon: nil)
	pbPrepPokemonContest(rank, category, pokemon)
	return if !$PokemonGlobal.pokemonContest
	pbCurrentPokemonContest.pbIntroductionRound
	pbCurrentPokemonContest.pbTalentRound
	pbCurrentPokemonContest.pbResults
	pbEndPokemonContest
end

#====================================================================================
#  Setup In Lobby
#====================================================================================
def pbPrepPokemonContest(rank = nil, category = nil, pokemon = nil)
	if $player.party.size <=0
		pbMessage(_INTL("¡Oh, no tenés ningún Pokémon!"))
		pbMessage(_INTL("Por favor regresá cuando tengas uno."))
		return
	end
	if ContestSettings::REQUIRE_CONTEST_PASS_ITEM && !$bag.has?(:CONTESTPASS)
		pbMessage(_INTL("¡Oh, no tenés un pase de concursos!"))
		pbMessage(_INTL("Por favor regresá cuando tengas uno."))
		return
	end
	rank = ContestFunctions.sanitizeRank(rank)
	category = ContestFunctions.sanitizeCategory(category)
	pbMessage(_INTL("¡Hola!"))
	pbMessage(_INTL("Esta es la recepción para los concursos Pokémon."))
	cmds = [_INTL("Entrar"),_INTL("Cancelar")]
	if rank || category
		rankName = ContestFunctions.getRankName(rank,true)
		catName = ContestFunctions.getCategoryName(category,true)
		pbMessage(_INTL("Estamos aceptando inscripciones {1}{2}Concursos Pokémon.",rankName,catName))
		choice = pbMessage(_INTL("¿Quieres inscribir a tu Pokémon en un {1}{2}?",rankName,catName),cmds,-1)	
	else
		choice = pbMessage(_INTL("¿Quieres inscribir a tu Pokémon en un Concurso?"),cmds,-1)
	end
	return pbMessage(_INTL("Esperemos participes en otra ocasión.")) if choice < 0 || choice == 1
	#Choose Category
	if !category
		cmds_c = [_INTL("#{pbContestCatName(0)}"), _INTL("#{pbContestCatName(1)}"), _INTL("#{pbContestCatName(2)}"), _INTL("#{pbContestCatName(3)}"), _INTL("#{pbContestCatName(4)}"), _INTL("Salir")]
		cat = pbMessage(_INTL("¿En qué concurso te gustaría participar?"), cmds_c, -1)
		return pbMessage(_INTL("Esperemos participes en otra ocasión.")) if cat < 0 || cat == 5
		category = cat
	end
	#Choose Rank
	if !rank
		cmds_r = [_INTL("Rango Normal"), _INTL("Super Rango"), _INTL("Rango Hiper"), _INTL("Rango Maestro"), _INTL("Salir")]
		rnk = pbMessage(_INTL("¿A qué rango le gustaría ingresar?"), cmds_r, -1)
		return pbMessage(_INTL("Esperamos que participes en otra ocasión.")) if rnk < 0 || rnk == 4
		rank = rnk
	end
	#Choose Pokemon
	loop do
		if !pokemon
			pbMessage(_INTL("¿Qué Pokémon te gustaría ingresar?"))
			if rank == 0
				pbChoosePokemon(1, 3, proc { |p| !p.egg? && !(p.shadowPokemon? rescue false)})
				pkmn = pbGet(1)
			else
				ribbon = ContestSettings::CONTEST_RIBBONS[category][rank-1]
				pbChoosePokemon(1, 3, proc { |p| !p.egg? && !(p.shadowPokemon? rescue false) && p.hasRibbon?(ribbon)})
				pkmn = pbGet(1)
			end
		end
		pokemon = pkmn
		if pokemon < 0
			if pbConfirmMessage(_INTL("¿Cancelar participación?"))
				return pbMessage(_INTL("Esperamos que participes en otra ocasión."))
			else
				#pbMessage(_INTL("Which Pokémon would you like to enter?"))
				pokemon = nil
				next
			end
		end	
		#Pokemon has Ribbon
		if $player.party[pokemon].hasRibbon?(ContestSettings::CONTEST_RIBBONS[category][rank])
			pbMessage(_INTL("Oh, esa cinta..."))
			pbMessage(_INTL("Tu {1} Ha ganado este concurso antes, ¿no?", $player.party[pokemon].name))
			if pbConfirmMessage(_INTL("¿Te gustaría participar en este Concurso de todos modos?"))
				
			else
				#pbMessage(_INTL("Which Pokémon would you like to enter?"))
				pokemon = nil
				next
			end
		end
		if pbConfirmMessage(_INTL("Registrar a {1} en el concurso?",$player.party[pokemon].name))
			#return pbMessage(_INTL("We hope you will participate another time."))
		else
			#pbMessage(_INTL("Which Pokémon would you like to enter?"))
			pokemon = nil
			next
		end	
		break
	end
	# if pbConfirmMessage("Cancel participation?")
		# return pbMessage(_INTL("We hope you will participate another time."))
	# else
		# pbMessage(_INTL("Which Pokémon would you like to enter?"))
		# pokemon = nil
		# next
	# end
	pbMessage(_INTL("Ok, tu {1} participará en este Concurso.", $player.party[pokemon].name))
	pbMessage(_INTL("{1} es el participante Número 4. El concurso empezará en unos momentos.", $player.party[pokemon].name))	
	pbCurrentPokemonContest.set(rank, category, pokemon, ContestFunctions.getHallMapInfo(rank, category), ContestFunctions.getReturnMapInfo(rank, category))
	ContestFunctions.bringPlayerToContestHall
	return true
end

#====================================================================================
#  End the Contest
#====================================================================================

def pbEndPokemonContest
	ContestFunctions.bringPlayerToLobby
	$PokemonGlobal.pokemonContest = nil
	$PokemonGlobal.nextContestTrainerOne = nil
	$PokemonGlobal.nextContestTrainerTwo = nil
	$PokemonGlobal.nextContestTrainerThree = nil
	
end

#====================================================================================
#  Misc Contest Functions
#====================================================================================

module ContestFunctions
	module_function
	
	def bringPlayerToContestHall
		map = $game_map.map_id
		guideEvent = $game_map.events[ContestSettings::FRONT_DESK_GUIDE_EVENT]
		doors = ContestSettings::FRONT_DESK_DOOR_EVENTS
		# Front Desk Guide
		pbMoveRoute(guideEvent,[PBMoveRoute::LEFT,
			PBMoveRoute::LEFT,PBMoveRoute::TURN_DOWN])
		pbWaitForCharacterMove(guideEvent)
		pbWait(0.2)
		doors.length.times{ |i| $game_self_switches[[map, doors[i], 'A']] = true; $game_map.need_refresh = true} # Front Desk Door
		pbMoveRoute(guideEvent,[PBMoveRoute::DOWN,PBMoveRoute::DOWN])
		pbWaitForCharacterMove(guideEvent)
		pbWait(0.2)
		doors.length.times{ |i| $game_self_switches[[map, doors[i], 'A']] = false; $game_map.need_refresh  = true} # Front Desk Door
		pbWait(0.2)
		pbMoveRoute(guideEvent,[PBMoveRoute::TURN_RIGHT])
		pbWaitForCharacterMove(guideEvent)
		pbMoveRoute($game_player,[PBMoveRoute::TURN_LEFT])
		pbWaitForCharacterMove($game_player)
		pbMessage(_INTL("Por favor, sígueme."))
		pbMoveRoute($game_player,[PBMoveRoute::LEFT])
		pbWaitForCharacterMove($game_player)
		pbMoveRoute(guideEvent,[PBMoveRoute::TURN180])
		pbWaitForCharacterMove(guideEvent)
		pbMoveRoute(guideEvent,[PBMoveRoute::LEFT,PBMoveRoute::LEFT,
			PBMoveRoute::LEFT,PBMoveRoute::UP,PBMoveRoute::UP,PBMoveRoute::TURN180])
		pbWait(0.2)
		pbMoveRoute($game_player,[PBMoveRoute::LEFT,PBMoveRoute::LEFT,PBMoveRoute::LEFT,
			PBMoveRoute::LEFT,PBMoveRoute::UP])
		pbWaitForCharacterMove($game_player)
		pbMessage(_INTL("Por favor, entra por aquí. ¡Buena suerte!"))
		pbMoveRoute($game_player,[PBMoveRoute::LEFT,PBMoveRoute::UP,PBMoveRoute::UP])
		pbWaitForCharacterMove($game_player)
		hallInfo = pbCurrentPokemonContest.hallMapInfo
		self.transfer(*hallInfo,8)
		pbScrollMap(8, 2, 3)
		pbScrollMap(4, 3, 3)
	end
	
	def bringPlayerToLobby
		returnInfo = pbCurrentPokemonContest.returnMapInfo
		self.transfer(*returnInfo)

	end

	def set_switch(map, event, switch='A', set=true)
		$game_self_switches[[map, event, switch]] = set
		return unless set
		$game_map.need_refresh = set
		loop do
			break if !$game_self_switches[[map, event, switch]]
			pbWait(0.2)
		end
	end
		
	def transfer(id, x, y, dir)
		if $scene.is_a?(Scene_Map)
			pbFadeOutIn {
				$game_temp.player_transferring   = true
				$game_temp.transition_processing = true
				$game_temp.player_new_map_id    = id
				$game_temp.player_new_x         = x
				$game_temp.player_new_y         = y
				$game_temp.player_new_direction = dir
				pbWait(0.5)
				$scene.transfer_player
				pbWait(0.2)
			}
		end
	end
	
	def getHallMapInfo(rank, category)
		get = ContestSettings::ROOM_MAP_COORDINATES[rank][category]
		get = ContestSettings::ROOM_MAP_COORDINATES[rank][0] if !get
		return get
	end
	
	def getReturnMapInfo(rank, category)
		get = ContestSettings::LOBBY_MAP_COORDINATES[rank][category]
		get = ContestSettings::DEFAULT_RETURN_COORDINATES if !get
		return get
	end
	
	def sanitizeRank(rank)
		return nil if rank == nil
		return rank if rank.is_a?(Integer) && [0,1,2,3].include?(rank)
		rank = rank.to_s if rank.is_a?(Symbol)
		rank = rank.upcase if rank.is_a?(String)
		case rank
		when "NORMAL" then rank = 0
		when "SUPER" then rank = 1
		when "HYPER" then rank = 2
		when "MASTER" then rank = 3
		else rank = nil; end		
		return rank
	end
	
	def sanitizeCategory(category)
		return nil if category == nil
		return category if category.is_a?(Integer) && [0,1,2,3,4].include?(category)
		return GameData::ContestType.get(category).icon_index if category.is_a?(Symbol)
		category = category.upcase if category.is_a?(String)
		GameData::ContestType.each { |type|
			return type.icon_index if [type.name.upcase,type.long_name.upcase].include?(category)
		}
		return nil
	end
	
	def getRankName(int,spaceAfter=false)
		return "" if !int
		arr = ["Normal Rank","Super Rank","Hyper Rank","Master Rank"]
		return arr[int] + (spaceAfter ? " " : "")
	end
	
	def getRankNameShort(int,spaceAfter=false)
		return "" if !int
		arr = ["Normal","Super","Hyper","Master"]
		return arr[int] + (spaceAfter ? " " : "")
	end
	
	def getCategoryName(int,spaceAfter=false)
		return "" if !int
		arr = []
		GameData::ContestType.each { |type|
			arr.push(type.long_name)
		}
		return arr[int] + (spaceAfter ? " " : "")
	end
	
	def getCategoryNameShort(int,spaceAfter=false)
		return "" if !int
		arr = []
		GameData::ContestType.each { |type|
			arr.push(type.name)
		}
		return arr[int] + (spaceAfter ? " " : "")
	end
	
end

def pbContestCatName(int,spaceAfter=false)
	return ContestFunctions.getCategoryName(int,spaceAfter)
end

def pbContestCatShortName(int,spaceAfter=false)
	return ContestFunctions.getCategoryNameShort(int,spaceAfter)
end

class ContestTrainerSprite
	def initialize(event, map, _viewport)
		@event     = event
		@id		   = event.id
		@map       = map
		@disposed  = false
		@event.character_name = ""
		set_event_graphic   # Set the event's graphic
	end

	def dispose
		@event    = nil
		@map      = nil
		@disposed = true
	end

	def disposed?
		@disposed
	end

	def set_event_graphic
		if @id == ContestSettings::TRAINER_NPC_ONE_EVENT
			@event.character_name = pbCurrentPokemonContest.trainerOne.character_sprite
		elsif @id == ContestSettings::TRAINER_NPC_TWO_EVENT
			@event.character_name = pbCurrentPokemonContest.trainerTwo.character_sprite
		elsif @id == ContestSettings::TRAINER_NPC_THREE_EVENT
			@event.character_name = pbCurrentPokemonContest.trainerThree.character_sprite
		end
	end

	def update
		set_event_graphic
	end
end


EventHandlers.add(:on_new_spriteset_map, :add_contest_trainer_graphics,
  proc { |spriteset, viewport|
    map = spriteset.map
    map.events.each do |event|
      next if !event[1].name[/contesttrainer/i]
      spriteset.addUserSprite(ContestTrainerSprite.new(event[1], map, viewport))
    end
  }
)