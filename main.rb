require_relative "lib/omega"

require_relative "isomap"
require_relative "cursor"
require_relative "itemmenu"

require_relative "playstate"
require_relative "explorationstate"
require_relative "resource"
require_relative "textdamage"
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
        "hit_hero" => Gosu::Sample.new("assets/sounds/hit_hero.wav"),
        "hit_monster" =>  Gosu::Sample.new("assets/sounds/hit_monster.wav"),
        "monster_die" => Gosu::Sample.new("assets/sounds/monster_die.wav"),
        "throw_brick" => Gosu::Sample.new("assets/sounds/throw_brick.wav")
    }

    def load
        Omega.set_state(ExplorationState.new)
    end
    
end

Omega.run(Game, "config.json")
