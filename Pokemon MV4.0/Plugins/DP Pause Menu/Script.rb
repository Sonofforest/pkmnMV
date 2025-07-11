#==============================================================================#
#                         Diamond/Pearl Pause Menu                             #
#                                  by Marin                                    #
#==============================================================================#
#                                Instructions                                  #
#                                                                              #
#  To call the Pause menu individually (not by pressing B), use `pbPauseMenu`  #
#                                                                              #
# To make/add your own options, find `@options = []`. Underneath, all options  #
#        are initialized and added. They follow a very simple format:          #
#           [displayname, unselected, selected, code, (condition)]             #
# `displayname` : This is what's actually displayed on screen.                 #
# `unselected` : This is the icon that will be displayed when the option is    #
#                NOT selected. For it to be gender dependent, make it an array #
# `selected` : This is the icon that will be displayed when the option IS      #
#              selected. For it to be gender dependent, make it an array.      #
# `code` : This is what's executed when you click the button.                  #
# `condition` : If you only want the option to be visible at certain times,    #
#               this is where you can add a condition (e.g. $player.pokedex). #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#

# Calls the Pause menu
def pbPauseMenu
  DP_PauseMenu.new
end

# This overwrites the old pause menu. Take/comment out these 10 lines to keep
# the old Pause menu.
class Scene_Map
  def call_menu
    $game_temp.menu_calling = false
    $game_temp.in_menu = true
    $game_player.straighten
    $game_map.update
    pbPauseMenu # Calls the DP Pause Menu
    $game_temp.in_menu = false
  end
end

# Variables used to store last selected index.
class PokemonGlobalMetadata
  attr_accessor :last_menu_index
end

class DP_PauseMenu
  # Base color of the displayed text
  BaseColor = Color.new(82,82,90)
  # Shadow color of the displayed text
  ShadowColor = Color.new(165,165,173)
  
  def initialize
    @options = []
    @options << ["Pokédex", "pokedexA", "pokedexB", proc {
      if Settings::USE_CURRENT_REGION_DEX
        pbFadeOutIn do
          scene = PokemonPokedex_Scene.new
          screen = PokemonPokedexScreen.new(scene)
          screen.pbStartScreen
        end
      elsif $player.pokedex.accessible_dexes.length == 1
        $PokemonGlobal.pokedexDex = $player.pokedex.accessible_dexes[0]
        pbFadeOutIn do
          scene = PokemonPokedex_Scene.new
          screen = PokemonPokedexScreen.new(scene)
          screen.pbStartScreen
        end
      else
        pbFadeOutIn do
          scene = PokemonPokedexMenu_Scene.new
          screen = PokemonPokedexMenuScreen.new(scene)
          screen.pbStartScreen
        end
      end 
    }] if $player.has_pokedex
    @options << ["Pokémon", "pokemonA", "pokemonB", proc {
      hiddenmove = nil
      pbFadeOutIn(99999) do
        sscene = PokemonParty_Scene.new
        sscreen = PokemonPartyScreen.new(sscene, $player.party)
        hiddenmove = sscreen.pbPokemonScreen
        if hiddenmove
          @sprites.visible = false
          @done = true
        end
      end
      if hiddenmove
        $game_temp.in_menu = false
        Kernel.pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
      end
    }] if $player.party.size > 0
    @options << ["Bolsa", "bagA", ["bagBm", "bagBf"], proc {
      item = 0
      pbFadeOutIn(99999) do
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene, $bag)
        item = screen.pbStartScreen
      end
      next false if !item
      $game_temp.in_menu = false
      pbUseKeyItemInField(item)
      next true
    }]
    @options << [$player.name, "PlayercardA", "PlayercardB", proc {
      pbFadeOutIn(99999) do
        scene = PokemonTrainerCard_Scene.new
        screen = PokemonTrainerCardScreen.new(scene)
        screen.pbStartScreen
      end
    }]
    @options << ["Guardar", "saveA", ["saveBm","saveBf"], proc {
      @sprites.visible = false
      scene = PokemonSave_Scene.new
      screen = PokemonSaveScreen.new(scene)
      if screen.pbSaveScreen
        @done = true
      else
        @sprites.visible = true
      end
    }]
    @options << ["Opciones", "optionsA", "optionsB", proc {
      pbFadeOutIn(99999) do
        scene = PokemonOption_Scene.new
        screen = PokemonOptionScreen.new(scene)
        screen.pbStartScreen
        pbUpdateSceneMap
      end
    }]
    
    @options <<["PokeNAV","pokenavA","pokenavB",proc{
      pbFadeOutIn(99999) do
      scene = PokemonPokenav_Scene.new
      screen = PokemonPokenavScreen.new(scene)
      item =  screen.pbStartScreen
    end
    next pbFlyToNewLocation
    }]
    @options << ["Salir", "exitA", "exitB", proc {
      @done = true
    }]
    @count = @options.size
    return if @count == 0
    $PokemonGlobal.last_menu_index ||= 0
    @option = $PokemonGlobal.last_menu_index
    @option = 0 if @option >= @options.size
    @done = false
    @i = 0
    @scaling = 0
    @viewport = Viewport.new(Graphics.width - 204, 4, 200, 24 + 48 * @count)
    @viewport.z = 99999
    @sprites = SpriteHash.new
    @sprites["bgTop"] = Sprite.new(@viewport)
    @sprites["bgTop"].bmp("Graphics/Pictures/DP Pause Menu/bgTop")
    @sprites["bgMid"] = Sprite.new(@viewport)
    @sprites["bgMid"].bmp("Graphics/Pictures/DP Pause Menu/bgMid")
    @sprites["bgMid"].y = 12
    @sprites["bgMid"].zoom_y = 48 * @count
    @sprites["bgBtm"] = Sprite.new(@viewport)
    @sprites["bgBtm"].bmp("Graphics/Pictures/DP Pause Menu/bgBtm")
    @sprites["bgBtm"].y = 12 + @sprites["bgMid"].zoom_y
    @sprites["sel"] = Sprite.new(@viewport)
    @sprites["sel"].bmp("Graphics/Pictures/DP Pause Menu/selector")
    @sprites["sel"].xyz = 8, 10 + 48 * @option, 1
    @sprites["txt"] = TextSprite.new(@viewport)
    for i in 0...@options.size
      @sprites["txt"].draw([
          @options[i][0],72,26 + 48 * i,0,BaseColor,ShadowColor
      ])
      @sprites[@options[i][0]] = Sprite.new(@viewport)
      idx = (i == @option ? 2 : 1)
      path = @options[i][idx]
      path = path[$player.gender] if path.is_a?(Array)
      @sprites[@options[i][0]].bmp("Graphics/Pictures/DP Pause Menu/#{path}")
      @sprites[@options[i][0]].center_origins
      @sprites[@options[i][0]].xyz = 39, 36 + 48 * i
    end
    pbSEPlay("GUI menu open")
    main
  end
  
  def main
    loop do
      update
      old = @option
      if Input.repeat?(Input::DOWN)
        @option += 1
        @option = 0 if @option == @count
        changed = true
      end
      if Input.repeat?(Input::UP)
        @option -= 1
        @option = @count - 1 if @option == -1
        changed = true
      end
      if $mouse
        for i in 0...@count
          if i != @option && $mouse.inArea?(316,14 + 48 * i,184,52)
            @option = i
            changed = true
          end
        end
      end
      confirmed = ($mouse && $mouse.x >= 316 && $mouse.x <= 500 && $mouse.y >= 14 &&
         $mouse.y <= 14 + 48 * @count && $mouse.click?)
      confirmed = true if Input.trigger?(Input::C)
      if changed
        pbPlayCursorSE
        $PokemonGlobal.last_menu_index = @option
        path = @options[old][1]
        path = path[$player.gender] if path.is_a?(Array)
        @sprites[@options[old][0]].bmp("Graphics/Pictures/DP Pause Menu/#{path}")
        @sprites[@options[old][0]].angle = 0
        @sprites[@options[old][0]].zoom_x = 1
        @sprites[@options[old][0]].zoom_y = 1
        @sprites["sel"].y = 10 + 48 * @option
        path = @options[@option][2]
        path = path[$player.gender] if path.is_a?(Array)
        @sprites[@options[@option][0]].bmp("Graphics/Pictures/DP Pause Menu/#{path}")
        changed = false
        @scaling = 0
      end
      if confirmed
        pbPlayDecisionSE
        @options[@option][3].call
        Input.update
      end
      confirmed = false
      if @done
        break
      elsif Input.trigger?(Input::B)
        pbPlayCancelSE
        break
      end
    end
    dispose
  end
  
  def update
    Graphics.update
    Input.update
    pbUpdateSceneMap
    if @scaling
      @scaling += 1
      case @scaling
      when 1..4
        @sprites[@options[@option][0]].zoom_x += 0.05
        @sprites[@options[@option][0]].zoom_y += 0.05
      when 8..12
        @sprites[@options[@option][0]].zoom_x -= 0.05
        @sprites[@options[@option][0]].zoom_y -= 0.05
      end
      @scaling = nil if @scaling == 12
    else
      @i += 1
      case @i
      when 1..6
        @sprites[@options[@option][0]].angle -= 2
      when 7..18
        @sprites[@options[@option][0]].angle += 2
      when 19..24
        @sprites[@options[@option][0]].angle -= 2
      end
      @i = 0 if @i == 24
    end
  end
  
  def dispose
    @sprites.dispose
    @viewport.dispose
    Input.update
  end
end