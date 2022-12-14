require_relative "lib/omega"

require_relative "isomap"
require_relative "cursor"
require_relative "itemmenu"

require_relative "cutscene"
require_relative "queststate"
require_relative "menustate"
require_relative "explorationstate"
require_relative "gameoverstate"
require_relative "backtovillagestate"
require_relative "textdamage"
require_relative "looticon"
require_relative "worldmapstate"
require_relative "hero/brick"
require_relative "hero/hero"
require_relative "hero/lootinfo"
require_relative "notification"
require_relative "monsters/monster"
require_relative "monsters/loot"
require_relative "monsters/rockdood"
require_relative "monsters/volcanicdood"
require_relative "monsters/smokey"
require_relative "monsters/whitesmokey"
require_relative "monsters/breakablerock"
require_relative "monsters/breakabletree"
require_relative "monsters/breakablecactus"
require_relative "monsters/breakablebush"
require_relative "monsters/breakablewindow"
require_relative "monsters/breakableHammer"

require_relative "constructionstate"

Gosu::enable_undocumented_retrofication

class Game < Omega::RenderWindow

    $base_font = Gosu::Font.new(50)
    $font = Gosu::Font.new(50, name: "assets/Perfect_DOS_VGA.ttf")

    $musics = {
        "boss" => Gosu::Song.new("assets/musics/boss.ogg"),
        "castle" => Gosu::Song.new("assets/musics/chaos_penguin_castle_ruins.ogg"),
        "chaos_penguin" => Gosu::Song.new("assets/musics/#@[°=%.ogg"),
        "construction_mode" => Gosu::Song.new("assets/musics/construction_mode.ogg"),
        "desert" => Gosu::Song.new("assets/musics/desert.ogg"),
        "forest" => Gosu::Song.new("assets/musics/forest.ogg"),
        "game_over" => Gosu::Song.new("assets/musics/game_over.ogg"),
        "intro" =>  Gosu::Song.new("assets/musics/intro.ogg"),
        "return_to_village" =>  Gosu::Song.new("assets/musics/return_to_village.ogg"),
        "title_screen" => Gosu::Song.new("assets/musics/title_screen.ogg"),
        "victory" => Gosu::Song.new("assets/musics/victory.ogg"),
        "world_map" => Gosu::Song.new("assets/musics/world_map.ogg")
    }

    $sounds = {
        "attack_pickaxe" => Gosu::Sample.new("assets/sounds/attack_pickaxe.wav"),
        "cancel" => Gosu::Sample.new("assets/sounds/cancel.wav"),
        "empty" => Gosu::Sample.new("assets/sounds/empty.wav"),
        "hit_hero" => Gosu::Sample.new("assets/sounds/hit_hero.wav"),
        "hit_monster" =>  Gosu::Sample.new("assets/sounds/hit_monster.wav"),
        "item_collected" => Gosu::Sample.new("assets/sounds/item_collected.wav"),
        "monster_die" => Gosu::Sample.new("assets/sounds/monster_die.wav"),
        "move_cursor" => Gosu::Sample.new("assets/sounds/move_cursor.wav"),
        "put_block" => Gosu::Sample.new("assets/sounds/put_block.wav"),
        "quest_finished" => Gosu::Sample.new("assets/sounds/quest_finished.wav"),
        "remove_block" => Gosu::Sample.new("assets/sounds/remove_block.wav"),
        "select" => Gosu::Sample.new("assets/sounds/select.wav"),
        "throw_brick" => Gosu::Sample.new("assets/sounds/throw_brick.wav"),
        "validate" => Gosu::Sample.new("assets/sounds/validate.wav"),
    }

    $inventory = {
        "Grass" => 0,
        "Stone" => 103,
        "Sand" => 0,
        "Water" => 100,
        "Wood" => 0,
        "Glass" => 0,
        "Dirt" => 3,
        "Cactus" => 0,
        "Bush" => 0
    }

    $hero_inventory = {
        "Grass" => 0,
        "Stone" => 0,
        "Sand" =>  0,
        "Water" => 0,
        "Wood" =>  0,
        "Glass" => 0,
        "Dirt"  => 0,
        "Cactus" => 0,
        "Bush" => 0
    }

    $current_map = "desert" # possible choices are: "forest" || "desert" || "castle"

    $quest_status = {
        "Fountain" => {"available" => true, "done" => false},
        "House" => {"available" => false, "done" => false},
        "Cult place" => {"available" => false, "done" => false},
        "Simple Garden" => {"available" => false, "done" => false},
        "Pyramid" => {"available" => false, "done" => false},
    }

    $quest = 1

    $quests_maps = []

    $construction_state = nil

    $rotation = 0

    def load_quests_map
        dir_size = Dir.entries("./assets/maps/quests")[2..-1].size
        for i in 1..dir_size
            $quests_maps << IsoMap.new("assets/ctileset.png", 1, 1)
            j = 0
            loop do
                path = "assets/maps/quests/quest_#{i}/quest_#{i}_layer_#{j}.csv"
                if File.exists?(path)
                    $quests_maps[i - 1].load_csv_layer(path)
                else
                    break
                end
                j += 1
            end
        end
    end

    def load
        load_quests_map()
        Omega.set_state(CutScene.new)
    end
   
end

Omega.run(Game, "config.json")
