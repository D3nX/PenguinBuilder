require_relative "lib/omega"

require_relative "playstate"
require_relative "explorationstate"
require_relative "hero"

Gosu::enable_undocumented_retrofication

class Game < Omega::RenderWindow

    def load
        Omega.set_state(ExplorationState.new)
    end
    
end

Omega.run(Game, "config.json")
