module Pokeathlon
	
	class Register_Athlon
		# Set quantity of pokemon who can play in this course
		# Don't touch it
		SIZE_PKMN = 3

		def self.talk
			registered = false

			# NPC
			pbMessage("¡Bienvenido!\nEsta es la recepción para la admisión.")
			mess = "¿Probarás el Pokeathlon?"
			arr  = ["Unirse", "Salir"]
			cmd  = pbMessage(mess, arr, arr.size) == 1
			if cmd
				pbMessage("¡Adiós! ¡Nos vemos pronto!")
				return
			end
			arr = [
				"Velocidad",
				"Fortaleza",
				"Precisión",
				"Resistencia",
				"Salto",
				"Cancelar"
			]
			mess = "¿Qué te gustaría probar?"
			cmd  = pbMessage(mess, arr, arr.size)
			case cmd
			when arr.size - 1 then pbMessage("¡Adiós! ¡Nos vemos pronto!")
			else
				if $player.party.size == 0
					pbMessage("¡Oh! ¡No tienes ningún Pokémon!")
					pbMessage("¡Adiós! ¡Nos vemos pronto!")
					return
				end
				infor = Pokeathlon.infor_course

				# Menu choose pokemon
				number = SIZE_PKMN
				ret   = Pokeathlon.chose_condition(number, true)
				if ret
					index = ret.values
					ret   = ret.keys
				end
				if !ret || ret.size < number
					pbMessage("¡Oh! ¡No quieres jugar!")
					pbMessage("¡Adiós! ¡Nos vemos pronto!")
					return registered
				end

				mess = "¿Quieres probar el minijuego de #{arr[cmd]} ?"
				if !pbConfirmMessage(mess)
					pbMessage("¡Oh! ¡No quieres jugar!")
					pbMessage("¡Adiós! ¡Nos vemos pronto!")
					return registered
				end

				pbMessage("Por favor, venga por aquí..")

				Pokeathlon.set_course_name(arr[cmd])
				ret.each_with_index { |pk, i| Pokeathlon.set_pkmn_infor_course(pk, $player.name, index[i]) }

				registered = true
			end

			return registered
		end
	end

	def self.register_athlon = Register_Athlon.talk

end