require_relative "lib/omega"

require_relative "isomap"
require_relative "cursor"
require_relative "itemmenu"

require_relative "queststate"
require_relative "playstate"
require_relative "explorationstate"
require_relative "resource"
require_relative "textdamage"
require_relative "brick"
require_relative "hero"
require_relative "notification"
require_relative "monsters/monster"
require_relative "monsters/loot"
require_relative "monsters/rockdood"

include Resource
require_relative "constructionstate"

Gosu::enable_undocumented_retrofication

class Game < Omega::RenderWindow

    $base_font = Gosu::Font.new(50)
    $font = Gosu::Font.new(50, name: "assets/Perfect_DOS_VGA.ttf")

    $sounds = {
        "attack_pickaxe" => Gosu::Sample.new("assets/sounds/attack_pickaxe.wav"),
        "cancel" => Gosu::Sample.new("assets/sounds/cancel.wav"),
        "hit_hero" => Gosu::Sample.new("assets/sounds/hit_hero.wav"),
        "hit_monster" =>  Gosu::Sample.new("assets/sounds/hit_monster.wav"),
        "item_collected" => Gosu::Sample.new("assets/sounds/item_collected.wav"),
        "monster_die" => Gosu::Sample.new("assets/sounds/monster_die.wav"),
        "select" => Gosu::Sample.new("assets/sounds/select.wav"),
        "throw_brick" => Gosu::Sample.new("assets/sounds/throw_brick.wav"),
        "validate" => Gosu::Sample.new("assets/sounds/validate.wav"),
    }

    $inventory = {
        "Grass" => 1000,
        "Stone" => 1000,
        "Sand" => 1000,
        "Water" => 1000,
        "Wood" => 1000,
        "Glass" => 1000,
        "Dirt" => 1000
    }

    $quest_status = {
        "Fountain" => {"available" => true, "done" => false},
        "House" => {"available" => false, "done" => false},
        "Bigger House" => {"available" => false, "done" => false}
    }

    $quest = 1

    $quests_maps = [
        IsoMap.new("assets/ctileset.png", 1, 1),
        IsoMap.new("assets/ctileset.png", 1, 1),
        IsoMap.new("assets/ctileset.png", 1, 1)
    ]

    def load_quests_map
        for i in 1..$quests_maps.size
            $quests_maps[i - 1].load_csv_layer("assets/maps/quests/quest_#{i}/quest_#{i}_layer_0.csv")
            $quests_maps[i - 1].load_csv_layer("assets/maps/quests/quest_#{i}/quest_#{i}_layer_1.csv")
            $quests_maps[i - 1].load_csv_layer("assets/maps/quests/quest_#{i}/quest_#{i}_layer_2.csv")
        end
    end

    def load
        load_quests_map()
        Omega.set_state(ConstructionState.new)
    end
    
end

Omega.run(Game, "config.json")
