require_relative "lib/omega"

require_relative "isomap"
require_relative "cursor"

require_relative "playstate"
require_relative "constructionstate"

Gosu::enable_undocumented_retrofication

class Game < Omega::RenderWindow

    def load
        Omega.set_state(ConstructionState.new)
    end
    
end

Omega.run(Game, "config.json")
