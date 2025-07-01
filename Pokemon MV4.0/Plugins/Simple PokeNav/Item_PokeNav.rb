ItemHandlers::UseFromBag.add(:POKENAV,proc { |item|
   scene = PokemonPokenav_Scene.new
   screen = PokemonPokenavScreen.new(scene)
   screen.pbStartScreen
   next 1
})

ItemHandlers::UseInField.add(:POKENAV,proc { |item|
   scene = PokemonPokenav_Scene.new
   screen = PokemonPokenavScreen.new(scene)
   screen.pbStartScreen
   next 1
})