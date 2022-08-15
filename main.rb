require_relative "lib/omega"

require_relative "playstate"
require_relative "explorationstate"
require_relative "resource"
require_relative "hero"
require_relative "monsters/monster"
require_relative "monsters/loot"
require_relative "monsters/rockdood"

include Resource

Gosu::enable_undocumented_retrofication

class Game < Omega::RenderWindow

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
