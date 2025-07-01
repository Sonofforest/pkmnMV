module Pokeathlon
	class JuiceBlender

		#--------------#
		# Check flavor #
		#--------------#
		def choose_feature_2_choose_3
			return if @choose != 3
			if !@sprites["check window"]
				text  = ""
				sum = $PokemonGlobal.apricorn_juice_flavor.inject(:+)
				sum = 100 if sum > 100
				text += "<ac>Check Flavor - Sum of flavors: #{sum}<ac>\n"
				text += text_check_flavor
				text += "<ac>Press USE or BACK key to exit<ac>"
				@sprites["check window"] = Window_AdvancedTextPokemon.new(_INTL(text))
				@sprites["check window"].resizeToFit(@sprites["check window"].text, Graphics.width)
				x = (Graphics.width - @sprites["check window"].width) / 2
				set_xy_sprite("check window", x, 0)
				@sprites["check window"].viewport = @viewport
			end

			loop do
				update_ingame
				# Update
				update_scene
				break if checkInput(Input::BACK) || checkInput(Input::USE)
			end

			# Dispose
			dispose("check window")
			@choose = 0
		end

		def text_check_flavor
			text = ""
			arr  = [:spicy, :sour, :dry, :bitter, :sweet]
			first  = $PokemonGlobal.apricorn_juice_strongest_first
			second = $PokemonGlobal.apricorn_juice_strongest_second
			third  = $PokemonGlobal.apricorn_juice_strongest_third
			flavor = $PokemonGlobal.apricorn_juice_flavor
			present = flavor.count { |f| f > 0 }
			# Strongest
			if !first.nil? && flavor[first] > 0
				arrtxt = [
					["Es un sabor picante.", "Un poco ácido.", "Un sabor refinado y seco.", "Un sabor algo amargo.", "Un sabor dulce."],
					["Un sabor picante.", "Un sabor vigorizante.", "¡Un sabor fuerte y seco!", "Un sabor ligeramente amargo.", "Un sabor agradable y dulce."],
					["¡Tan picante que sudarás!.", "¡Mmmmmph! ¡Agrio!", "¡Increíblemente seco!", "¡Un amargor intenso!", "¡Muy dulce!"],
					["¡Es tan picante que provoca tos!", "¡Insoportablemente doloroso!", "¡Un sabor seco y penetrante!", "¡Un sabor tremendamente amargo!", "¡Un sabor empalagoso!"],
					["¡Un picante rotundo!", "¡Una acidez profunda!", "¡Un sabor profundo y seco!", "¡Una amargura que se hunde!", "Una dulzura que se derrite en la boca."],
					["¡El picante definitivo!", "¡Un sabor extremadamente ácido!", "¡Un sabor extremadamente seco!", "¡El colmo de la amargura!", "¡Tan increíblemente dulce!"]
				]
				txt = 
					case flavor[first]
					when 1..20  then arrtxt[0][first]
					when 21..30 then arrtxt[1][first]
					when 31..40 then arrtxt[2][first]
					when 41..50 then arrtxt[3][first]
					when 51..62 then arrtxt[4][first]
					when 63     then arrtxt[5][first]
					end
				text += "<ac>#{txt}<ac>\n"
			end
			# Second (strongest)
			if flavor[second] > 0
				arrtxt = [
					["Un toque picante.", "Un toque ácido.", "Un sabor ligeramente seco.", "Apenas un toque amargo.", "Apenas un toque dulce."],
					["Un poco salado.", "Un poco ácido.", "Un sabor ligeramente seco.", "Solo un poco amargo.", "Solo un poco dulce."],
					["Bastante picante.", "Bastante ácido.", "Un sabor bastante seco.", "Un sabor fuertemente amargo.", "Un sabor fuertemente dulce."],
					["Un fuerte picante.", "Intensamente ácido.", "Un sabor intensamente seco.", "Intensamente amargo.", "Un sabor intensamente dulce."]
				]
				txt = 
					case flavor[second]
					when 1..20  then arrtxt[0][second]
					when 21..30 then arrtxt[1][second]
					when 31..40 then arrtxt[2][second]
					else
						arrtxt[3][second]
					end
				text += "<ac>#{txt}<ac>\n"
			end
			# Third
			if flavor[third] && present != 5
				arrtxt = [
					["Un ligero toque picante.", "Una ligera acidez.", "Un ligero sabor seco.", "Un ligero amargor.", "Un ligero dulzor."],
					["Un ligero toque picante.", "Un ligero toque de acidez.", "Un ligero sabor seco.", "Un ligero toque de amargor.", "Un ligero toque de dulzor."],
					["Se percibe el picante.", "Se percibe la acidez.", "Se percibe la sequedad.", "Se percibe el amargor.", "Se percibe el dulzor."]
				]
				txt = 
					case flavor[third]
					when 1..10  then arrtxt[0][third]
					when 11..20 then arrtxt[1][third]
					else
						arrtxt[2][third]
					end
				text += "<ac>#{txt}<ac>\n"
			end
			# Add new text
			if present >= 4
				# 1 - 7
				text += "<ac>bastante débil<ac>\n" if (!first.nil? && flavor[first].between?(1, 7)) || (first.nil? && second && flavor[second].between?(1, 7))
				# 8 - 20
				if (!first.nil? && flavor[first].between?(8, 20)) || (first.nil? && second && flavor[second].between?(8, 20))
					if present == 4
						text += "<ac>Indescriptiblemente increíble<ac>\n" if (!first.nil? && second && (flavor[first] - flavor[second]).between?(1, 12)) || (first.nil? && second && third && (flavor[second] - flavor[third]).between?(1, 12))
					elsif present == 5
						text += "<ac>Equilibrado uniformemente<ac>\n" if (!first.nil? && second && flavor[second].between?(1, 12)) || (first.nil? && second && third && flavor[third].between?(1, 12))
					end
				# 21 +
				elsif (!first.nil? && flavor[first] > 20) || (first.nil? && second && flavor[second] > 20)
					txt = present == 4 ? "Incredibly unspeakable" : "Competing"
					text += "<ac>#{txt}<ac>\n"
				end
			end
			# New text
			text += "<ac>Regusto refrescante<ac>\n" if present.between?(1, 2)
			text += "<ac>Regusto repugnante<ac>\n" if present == 5
			if present == 4
				index = flavor.index(0)
				text += "<ac>Eliminando #{arr[index]}<ac>\n"
			end
			return text
		end

	end
end