class PlayState < Omega::State

    def load
        @text = Omega::Text.new("HELLO WORLD", Gosu::Font.new(90))
        @text.set_position((Omega.width - @text.width) / 2,
                            (Omega.height - @text.height) / 2)

        @camera = Omega::Camera.new(false)
    end

    def update
        @camera.shake(20, -100, 100) if @camera.shake_finished
    end

    def draw
        @camera.draw do
            @text.draw()
        end
    end

end
