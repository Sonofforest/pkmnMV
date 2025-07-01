module Pokeathlon
	class CheckStats

		def draw_text
			draw_information
		end

		def draw_information(expand=false)
			clearTxt("pkmn text")
			return if !@pkmn[:name]
			pkmn = @pkmn[:name]
			text = []
			# Color (PE)
			base   = Color.new(248,248,248)
    	shadow = Color.new(104,104,104)
			# Page name
			string = "Rendimiento"
			x = 306 + 10
			y = 22 - 1 - 4
			#if expand
			#	SHOW_WIDTH ? (x += Settings::SCREEN_WIDTH) : (y += Settings::SCREEN_HEIGHT)
			#end
			text << [string, x, y, 0, base, shadow]
			# Name
			string = pkmn.name
			x = 320 + 32 + 2
			y = 70 - 4 - 2
		#	if expand
		#		SHOW_WIDTH ? (x += Settings::SCREEN_WIDTH) : (y += Settings::SCREEN_HEIGHT)
		#	end
			text << [string, x, y, 0, base, shadow]
			# Level
			string = "Lv.#{pkmn.level.to_s}"
			x = 320 + 5
			y = 109 - 10 - 2
		#	if expand
		#		SHOW_WIDTH ? (x += Settings::SCREEN_WIDTH) : (y += Settings::SCREEN_HEIGHT)
		#	end
			text << [string, x, y, 0, Color.new(64,64,64), Color.new(176,176,176)]
			# Item
			string = "ITEM"
			x = 320 + 5
			y = 320 - 4 - 2
		#	if expand
		#		SHOW_WIDTH ? (x += Settings::SCREEN_WIDTH) : (y += Settings::SCREEN_HEIGHT)
		#	end
			text << [string, x, y, 0, base, shadow]
			x = 320 + 5
			y = 354 - 5 - 2
			#if expand
			#	SHOW_WIDTH ? (x += Settings::SCREEN_WIDTH) : (y += Settings::SCREEN_HEIGHT)
			#end
			if pkmn.hasItem?
				text << [pkmn.item.name, x, y, 0, Color.new(64,64,64), Color.new(176,176,176)]
			else
				text << [_INTL("Ninguno"), x, y, 0, Color.new(192,200,208), Color.new(208,216,224)]
			end
			# Write the gender symbol
			x = 496
			y = 63 - 4
		#	if expand
			#	SHOW_WIDTH ? (x += Settings::SCREEN_WIDTH) : (y += Settings::SCREEN_HEIGHT)
			#end
			if pkmn.male?
				text << [_INTL("♂"), x, y, 0, Color.new(24,112,216), Color.new(136,168,208)]
			elsif pkmn.female?
				text << [_INTL("♀"), x, y, 0, Color.new(248,56,32), Color.new(224,152,144)]
			end
			drawTxt("pkmn text", text)
			# Draw image
			imagepos = []
			# Show the Poké Ball containing the Pokémon
			ballimage = sprintf("Graphics/UI/Summary/icon_ball_%s", pkmn.poke_ball)
			ballimage = sprintf("Graphics/UI/Summary/icon_ball_%02d", pbGetBallType(pkmn.poke_ball)) if !pbResolveBitmap(ballimage)
			x = 320
			y = 63 - 1
		#	if expand
		#		SHOW_WIDTH ? (x += Settings::SCREEN_WIDTH) : (y += Settings::SCREEN_HEIGHT)
		#	end
			imagepos << [ballimage, x, y]
			# Show status/fainted/Pokérus infected icon
			status = 
				if pkmn.fainted?
					GameData::Status::DATA.keys.length / 2
				elsif pkmn.status != :NONE
					GameData::Status.get(pkmn.status).id_number
				elsif pkmn.pokerusStage == 1
					GameData::Status::DATA.keys.length / 2 + 1
				else
					0
				end
			status -= 1
			x = 490 - 44
			y = 96 + 12 - 16 / 2
		#	if expand
		#		SHOW_WIDTH ? (x += Settings::SCREEN_WIDTH) : (y += Settings::SCREEN_HEIGHT)
		#	end
			imagepos << ["Graphics/UI/statuses", x, y, 0, 16 * status, 44, 16] if status >= 0
			# Show Pokérus cured icon
			x = Graphics.width - 16
			y = 128 + 5
		#	if expand
		#		SHOW_WIDTH ? (x += Settings::SCREEN_WIDTH) : (y += Settings::SCREEN_HEIGHT)
		#	end
			imagepos << [sprintf("Graphics/UI/Summary/icon_pokerus"), x, y] if pkmn.pokerusStage == 2
			# Show shininess star
			y += 16 + 5 if pkmn.pokerusStage == 2
			#if expand
		#		SHOW_WIDTH ? (x += Settings::SCREEN_WIDTH) : (y += Settings::SCREEN_HEIGHT)
		#	end
			imagepos << [sprintf("Graphics/UI/shiny"), x, y] if pkmn.shiny?
			# Draw all images
			bitmap = @sprites["pkmn text"].bitmap
			pbDrawImagePositions(bitmap, imagepos)
		end

	end
end