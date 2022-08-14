require_relative "lib/omega"

require_relative "playstate"

Gosu::enable_undocumented_retrofication

class Game < Omega::RenderWindow

    def load
        Omega.set_state(PlayState.new)
    end
    
end

Omega.run(Game, "config.json")
