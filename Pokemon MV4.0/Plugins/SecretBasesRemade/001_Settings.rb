module SecretBaseSettings
  # Map ID used to load secret bases on
  # It is a dummy map, and can be left completely blank
  SECRET_BASE_MAP = 205
  # Map ID where items events are allocated
  SECRET_BASE_DECOR_MAP = 229
  # Tileset ID used for Secret Bases.
  SECRET_BASE_TILESET = 69
  # Move needed to make Secret Bases.
  SECRET_BASE_MOVE_NEEDED = :SECRETPOWER
  # Maximum number of decorations that can be placed at once.
  SECRET_BASE_MAX_DECORATIONS = 16
  # Allows placing :decor type decorations on the floor (true)
  # or if they can only be placed on SECRET_BASE_DECOR_FLOOR_TAG.
  SECRET_BASE_DECOR_ANYWHERE = false
  # Filename in Characters folder that the graphic of the PC.
  SECRET_BASE_PC_FILENAME = "secret_base_pc"
  # Messages and animation IDs for the secret entrances
  # the type of entrance set for the template in GameData::SecretBaseTemplate is used here
  #  to determine the messages and the animation when opening it.
  # :type => ["On Interact", "On Opening", Animation ID, Frame in Animation to Appear]
  SECRET_BASE_MESSAGES_ANIM={
                    :cave=>[_INTL("Hay una pequeña hendidura en la pared.."),
                            _INTL("¡Descubrí una pequeña caverna!"),
                            10,5],
                    :vines=>[_INTL("Si algunas vides caen, este árbol se puede escalar."),
                             _INTL("¡Una enredadera cayó!"),
                             10,-1],
                    :shrub=>[_INTL("Si se puede mover este montón de hierba, quizá sea posible entrar."),
                             _INTL("¡Descubrí una pequeña entrada!"),
                             10,-1]
                   }
  # Hole Locations in the Secret Base Tileset
  # [tile id, width in tiles, height in tiles]
  # Holes need to be in Layer 2.
  SECRET_BASE_HOLES=[
    [144,1,2],
    [146,2,1],
    [148,2,2],
  ]
  # Terrain tag for ground decorations that already are in    
  # base, for example rocks or bushes in layer 1
  # if your ground decoration is in layer 2 or 3, don't worry
  # about this.
  SECRET_BASE_GROUND_DECOR_TAG = :SecretGroundDecor
  # Terrain tag for walls                                     
  # You can post posters in every tile with this terrain tag
  SECRET_BASE_WALL_TAG = :SecretWall
  # Terrain tag for special items that can be used
  # to place :decor type decorations (if SECRET_BASE_DECOR_ANYWHERE is false)
  SECRET_BASE_DECOR_FLOOR_TAG = :SecretDecorFloor
  
  # The names of each pocket of the Secret Base Bag.
  def self.secret_bag_pocket_names
    return [
      _INTL("Desk"),
      _INTL("Chair"),
      _INTL("Plant"),
      _INTL("Ornament"),
      _INTL("Mat"),
      _INTL("Poster"),
      _INTL("Doll"),
      _INTL("Cushion")
    ]
  end
  # The maximum number of slots per pocket (-1 means infinite number).
  SECRET_BAG_MAX_POCKET_SIZE  = [10, 10, 10, 30, 30, 10, 40, 10]
  
  # Max bases that can be saved when record mixing (-1 means infinite number).
  SECRET_BASE_MAX_SAVED_BASES = 20
  # Max bases that can be registered
  SECRET_BASE_MAX_REGISTERED_BASES = 10
  
  # Skills for each Online Trainer Type
  SECRET_SKILLS_TRAINER_TYPE = {
    :POKEMONTRAINER_Red => [:EV_Training,:Give_Decoration,:Level_Training,:Egg_Care],
    :POKEMONTRAINER_Leaf => [:EV_Training,:Give_Decoration,:Level_Training,:Egg_Care]
  }
end

module MessageTypes
  SECRET_BASE_DECORATIONS_NAMES       = 28
  SECRET_BASE_DECORATION_DESCRIPTIONS = 29
end


GameData::TerrainTag.register({
  :id                     => :SecretGroundDecor,
  :id_number              => 26
})

GameData::TerrainTag.register({
  :id                     => :SecretWall,
  :id_number              => 27
})

GameData::TerrainTag.register({
  :id                     => :SecretDecorFloor,
  :id_number              => 28
})