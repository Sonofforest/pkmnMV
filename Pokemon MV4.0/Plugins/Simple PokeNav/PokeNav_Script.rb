#===============================================================================
# Simple PokeNav v1.0 by Richard PT
#===============================================================================
class PokenavButton < Sprite
  attr_reader :index
  attr_reader :name
  attr_reader :selected

  TEXT_BASE_COLOR = Color.new(248, 248, 248)
  TEXT_SHADOW_COLOR = Color.new(40, 40, 40)

  def initialize(command, x, y, viewport = nil)
    super(viewport)
    @image = command[0]
    @name  = command[1]
    @selected = false
    @button = AnimatedBitmap.new("Graphics/Pictures/Pokenav/icon_button")    
    @contents = BitmapWrapper.new(@button.width, @button.height)
    self.bitmap = @contents
    self.x = x - (@button.width / 2)
    self.y = y
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
    @button.dispose
    @contents.dispose
    super
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel != val
  end

  def refresh
    self.bitmap.clear
    rect = Rect.new(0, 0, @button.width, @button.height / 2)
    rect.y = @button.height / 2 if @selected
    self.bitmap.blt(0, 0, @button.bitmap, rect)
    textpos = [
      [@name, rect.width / 2, (rect.height / 2) - 10, 2, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]
    ]
    pbDrawTextPositions(self.bitmap, textpos)
    imagepos = [
      [sprintf("Graphics/Pictures/Pokenav/icon_" + @image), 8, 6] 
    ]
    pbDrawImagePositions(self.bitmap, imagepos)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokenav_Scene
  def pbUpdate
    @commands.length.times do |i|
      @sprites["button#{i}"].selected = (i == @index)
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(commands)
    @commands = commands
    @index = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Pokenav/bg")
    @commands.length.times do |i|
      @sprites["button#{i}"] = PokenavButton.new(@commands[i], Graphics.width / 2, 0, @viewport)
      button_height = @sprites["button#{i}"].bitmap.height / 2
      @sprites["button#{i}"].y = ((Graphics.height - (@commands.length * button_height)) / 2) + (i * button_height)
    end
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = @index
        break
      elsif Input.trigger?(Input::UP)
        pbPlayCursorSE if @commands.length > 1
        @index -= 1
        @index = @commands.length - 1 if @index < 0
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE if @commands.length > 1
        @index += 1
        @index = 0 if @index >= @commands.length
      end
    end
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    dispose
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokenavScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    # Get all commands
    command_list = []
    commands = []
    MenuHandlers.each_available(:pokenav_menu) do |option, hash, name|
      command_list.push([hash["icon_name"] || "", name])
      commands.push(hash)
    end
    @scene.pbStartScene(command_list)
    # Main loop
    end_scene = false
    loop do
      choice = @scene.pbScene
      if choice < 0
        end_scene = true
        break
      end
      break if commands[choice]["effect"].call(@scene)
    end
    @scene.pbEndScene if end_scene
  end
end

#===============================================================================
#
#===============================================================================
MenuHandlers.add(:pokenav_menu, :map, {
  "name"      => _INTL("Mapa"),
  "icon_name" => "map",
  "order"     => 10,
  "effect"    => proc { |menu|
    pbFadeOutIn {
      scene = PokemonRegionMap_Scene.new(-1, false)
      screen = PokemonRegionMapScreen.new(scene)
      ret = screen.pbStartScreen
      if ret
        $game_temp.fly_destination = ret
        menu.dispose
        next 99999
      end
    }
    next $game_temp.fly_destination
  }
})

MenuHandlers.add(:pokenav_menu, :buzz, {
  "name"      => _INTL("Buzz Nav"),
  "icon_name" => "buzz",
  "order"     => 20,
  "effect"    => proc { |menu|
    pbFadeOutIn { pbBuzzNav }
    next false
  }
})

MenuHandlers.add(:pokenav_menu, :phone, {
  "name"      => _INTL("Teléfono"),
  "icon_name" => "match",
  "order"     => 30,
  "condition" => proc { next $PokemonGlobal.phone && $PokemonGlobal.phone.contacts.length > 0 },
  "effect"    => proc { |menu|
    pbFadeOutIn do
      scene = PokemonPhone_Scene.new
      screen = PokemonPhoneScreen.new(scene)
      screen.pbStartScreen
    end
    next false
  }
})

MenuHandlers.add(:pokenav_menu, :social, {
  "name"      => _INTL("Social"),
  "icon_name" => "match",
  "order"     => 40,
  "condition" => proc { next $PokemonGlobal.phone && $PokemonGlobal.phone.contacts.length > 0 },
  "effect"    => proc { |menu|
    pbFadeOutIn { pbSocialLinks }
    next false
  }
})


MenuHandlers.add(:pokenav_menu, :ballCatch, {
  "name"      => _INTL("Atrapa Bayas"),
  "icon_name" => "catch",
  "order"     => 50,
  "effect"    => proc { |menu|
    pbFadeOutIn { pbCatchGame }
    next false
  }
})
=begin
MenuHandlers.add(:pokenav_menu, :berryDex, {
  "name"      => _INTL("BerryDex"),
  "icon_name" => "berry",
  "order"     => 60,
  "effect"    => proc { |menu|
    pbFadeOutIn { pbBerryDex }
    next false
  }
})
=end
