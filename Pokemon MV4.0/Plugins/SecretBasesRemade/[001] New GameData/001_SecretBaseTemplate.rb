module GameData
  class SecretBaseTemplate
    attr_reader :id
    attr_reader :map_id
    attr_reader :type
    attr_reader :door_location
    attr_reader :pc_location
    attr_reader :owner_location
    attr_reader :preview_steps
    attr_reader :map_borders

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id              = hash[:id]
      @map_id          = hash[:map_id]
      @type            = hash[:type]
      @door_location   = hash[:door_location]
      @pc_location     = hash[:pc_location]
      @owner_location  = hash[:owner_location]
      @preview_steps   = hash[:preview_steps] || 2
      @map_borders     = hash[:map_borders]
    end
  end
end

GameData::SecretBaseTemplate.register({
  :id             => :CaveRed1,
  :map_id         => 213,
  :type           => :cave,
  :door_location  => [13,14],
  :pc_location    => [9,8],
  :owner_location => [15,10],
  :map_borders    => [8,6,18,14]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveRed2,
  :map_id         => 214,
  :type           => :cave,
  :door_location  => [11,21],
  :pc_location    => [13,14],
  :owner_location => [11,7],
  :map_borders    => [8,6,14,21]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveRed3,
  :map_id         => 215,
  :type           => :cave,
  :door_location  => [11,13],
  :pc_location    => [9,8],
  :owner_location => [20,7],
  :map_borders    => [8,6,22,13]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveRed4,
  :map_id         => 216,
  :type           => :cave,
  :door_location  => [10,19],
  :pc_location    => [10,8],
  :owner_location => [13,14],
  :map_borders    => [8,6,16,20]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveBrown1,
  :map_id         => 209,
  :type           => :cave,
  :door_location  => [13,14],
  :pc_location    => [15,18],
  :owner_location => [13,8],
  :map_borders    => [8,6,18,14]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveBrown2,
  :map_id         => 210,
  :type           => :cave,
  :door_location  => [9,14],
  :pc_location    => [17,7],
  :owner_location => [19,8],
  :map_borders    => [8,6,21,14]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveBrown3,
  :map_id         => 211,
  :type           => :cave,
  :door_location  => [19,16],
  :pc_location    => [21,9],
  :owner_location => [9,13],
  :map_borders    => [8,6,22,16]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveBrown4,
  :map_id         => 212,
  :type           => :cave,
  :door_location  => [10,15],
  :pc_location    => [9,7],
  :owner_location => [10,7],
  :map_borders    => [8,6,21,17]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveBlue1,
  :map_id         => 230,
  :type           => :cave,
  :door_location  => [13,14],
  :pc_location    => [9,8],
  :owner_location => [12,8],
  :map_borders    => [8,6,18,14]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveBlue2,
  :map_id         => 206,
  :type           => :cave,
  :door_location  => [15,12],
  :pc_location    => [9,7],
  :owner_location => [10,7],
  :map_borders    => [8,6,22,12]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveBlue3,
  :map_id         => 207,
  :type           => :cave,
  :door_location  => [12,22],
  :pc_location    => [11,20],
  :owner_location => [13,7],
  :map_borders    => [8,6,17,22]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveBlue4,
  :map_id         => 208,
  :type           => :cave,
  :door_location  => [12,22],
  :pc_location    => [11,19],
  :owner_location => [13,19],
  :map_borders    => [8,6,16,22]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveYellow1,
  :map_id         => 217,
  :type           => :cave,
  :door_location  => [13,14],
  :pc_location    => [17,8],
  :owner_location => [11,7],
  :map_borders    => [8,6,18,14]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveYellow2,
  :map_id         => 218,
  :type           => :cave,
  :door_location  => [20,14],
  :pc_location    => [16,12],
  :owner_location => [9,7],
  :map_borders    => [8,6,21,14]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveYellow3,
  :map_id         => 219,
  :type           => :cave,
  :door_location  => [13,16],
  :pc_location    => [11,11],
  :owner_location => [15,11],
  :map_borders    => [8,6,19,16]
})

GameData::SecretBaseTemplate.register({
  :id             => :CaveYellow4,
  :map_id         => 220,
  :type           => :cave,
  :door_location  => [14,19],
  :pc_location    => [13,14],
  :owner_location => [17,14],
  :map_borders    => [8,6,20,19]
})

GameData::SecretBaseTemplate.register({
  :id             => :Tree1,
  :map_id         => 225,
  :type           => :vines,
  :door_location  => [6,9],
  :pc_location    => [3,3],
  :owner_location => [6,2],
  :map_borders    => [1,1,11,9]
})

GameData::SecretBaseTemplate.register({
  :id             => :Tree2,
  :map_id         => 226,
  :type           => :vines,
  :door_location  => [4,16],
  :pc_location    => [6,6],
  :owner_location => [4,2],
  :map_borders    => [1,1,7,16]
})

GameData::SecretBaseTemplate.register({
  :id             => :Tree3,
  :map_id         => 227,
  :type           => :vines,
  :door_location  => [9,8],
  :pc_location    => [16,3],
  :owner_location => [2,3],
  :map_borders    => [1,1,17,8]
})

GameData::SecretBaseTemplate.register({
  :id             => :Tree4,
  :map_id         => 228,
  :type           => :vines,
  :door_location  => [8,14],
  :pc_location    => [5,10],
  :owner_location => [11,10],
  :map_borders    => [1,1,14,14]
})

GameData::SecretBaseTemplate.register({
  :id             => :Shrub1,
  :map_id         => 221,
  :type           => :shrub,
  :door_location  => [6,9],
  :pc_location    => [4,3],
  :owner_location => [6,3],
  :map_borders    => [1,1,11,9]
})

GameData::SecretBaseTemplate.register({
  :id             => :Shrub2,
  :map_id         => 222,
  :type           => :shrub,
  :door_location  => [8,7],
  :pc_location    => [2,2],
  :owner_location => [14,3],
  :map_borders    => [1,1,15,7]
})

GameData::SecretBaseTemplate.register({
  :id             => :Shrub3,
  :map_id         => 223,
  :type           => :shrub,
  :door_location  => [7,11],
  :pc_location    => [8,8],
  :owner_location => [6,8],
  :map_borders    => [1,1,13,11]
})

GameData::SecretBaseTemplate.register({
  :id             => :Shrub4,
  :map_id         => 224,
  :type           => :shrub,
  :door_location  => [12,10],
  :pc_location    => [10,6],
  :owner_location => [10,8],
  :map_borders    => [1,1,14,11]
})