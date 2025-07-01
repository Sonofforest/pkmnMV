module Pokeathlon
	class CheckStats
		def update_main
			update_pkmn
			update_star
			update_marking
		end

		#-------------------------#
		# Update stats of pokemon #
		#-------------------------#
		def update_star
			5.times { |i|
				5.times { |j|
					set_visible_sprite("star #{i} #{j}", @pkmn[:name].athlon_max[i] > j)
					w = @sprites["star #{i} #{j}"].src_rect.width
					if @pkmn[:name].athlon_normal[i] == 0
						x = 0
					else
						x = @pkmn[:name].athlon_normal[i] - 1 < j ? 0 : w
					end
					set_src_xy_sprite("star #{i} #{j}", x, 0)
				}
			}
		end
	

		def drawMarkings(bitmap, x, y, _width, _height, markings)
			mark_variants = @markingbitmap.bitmap.height / 16
			markrect = Rect.new(0, 0, 16, 16)
			(@markingbitmap.bitmap.width / 16).times do |i|
				markrect.x = i * 16
				markrect.y = [(markings[i] || 0), mark_variants - 1].min * 16
				bitmap.blt(x + (i * 16), y, @markingbitmap.bitmap, markrect)
			end
		end


		#-------------------------#
		# Update pokemon (bitmap) #
		#-------------------------#
		def update_pkmn
			pkmn = @pkmn[:name]
			species = pkmn.species
			species = GameData::Species.get(species).species
			file = GameData::Species.sprite_filename(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?, false, pkmn.egg?)
			@sprites["pkmn"].bitmap = Bitmap.new(file)
		end

		#---------------------------#
		# Update marking of pokemon #
		#---------------------------#
		def update_marking
			@markingbitmap = AnimatedBitmap.new("Graphics/UI/Storage/markings")
			mark_variants = @markingbitmap.bitmap.height / 16
			markrect = Rect.new(0, 0, 16, 16)
			pkmn = @pkmn[:name]
			markings = pkmn.markings
			6.times { |i|
			markrect.x = i * 16
			markrect.y = [(markings[i] || 0), mark_variants - 1].min * 16
			}
		end
	end
end