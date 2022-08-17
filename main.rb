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
        "Grass" => 7,
        "Stone" => 2,
        "Sand" => 6,
        "Water" => 1,
        "Wood" => 3,
        "Glass" => 4
    }

    $quest_name = [
        "Fountain",
        "House",
        "Bigger House"
    ]

    $quest = 1

    def load
        Omega.set_state(QuestState.new)
    end
    
end

Omega.run(Game, "config.json")
