class ExplorationState < Omega::State

    def load
        @camera = Omega::Camera.new(false)
        @camera.scale = Omega::Vector2.new(3, 3)
        
        @hero = Hero.new(@camera);
        @camera.follow(@hero, 0.4)
    end

    def update
       @hero.update();
    end

    def draw
        @camera.draw do
            @hero.draw();
        end
    end

end