module Pokeathlon
	class JuiceBlender

		# Write guide
		def guide_mess
			arr = [
				"Puedes poner de 1 a 5 albaricoques a la vez, pero esto no producirá una bebida instantánea.",
				"Debes caminar o andar en bicicleta 100 pasos para licuar los albaricoques.",
				"Una vez que se termina de mezclar un lote de albaricoques, se pueden agregar más.",
				"Puedes consultar el sabor para conocer el sabor del albaricoque.",
				"Si la suma de sabores es mayor a 100, se elige el sabor más fuerte entre los que no fueron potenciados con la adición del albaricoque.",
				"(si hay empate se elige el primero entre el orden de Fortaleza, Resistencia, Presición, Salto y Velocidad)",
				"Se elige un sabor aleatorio si se agregó un albaricoque negro, y no se elige ningún sabor si se agregó un albaricoque blanco.",
				"En 'Verificar sabor', solo muestra 100 si la suma de sabores es mayor que 100.",
				"Cada 100 pasos dados aumenta la suavidad de un Aprijuice en 1, hasta un máximo de 255."
			]
			arr.each { |i| update_message(i) }
		end

	end
end