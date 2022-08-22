class CutScene < Omega::State

    MAX_TIMER = 350

    def load_bgs
        @bg = [
            Omega::Sprite.new("assets/cutscenes/slide_0.png"),
            Omega::Sprite.new("assets/cutscenes/slide_1.png"),
            Omega::Sprite.new("assets/cutscenes/slide_2.png")
        ]
    end

    def load_text
        @text = Omega::Text.new(60, $font)
        @desc = [
            "A long time ago... When the Chaos Penguin\nseeked to destroy the lands...",
            "A young hero came to the rescue and\nsaved the realm. But now the land is saved,\n",
            "It's up to you to rebuild the kingdom!"
        ]
    end

    def load
        @current_slide = 0
        @alpha = 255
        @timer = 0
        @exit = false
        
        load_bgs()
        load_text()

        $musics["intro"].play(true)
    end

    def update
        if Omega::just_pressed(Gosu::KB_X) or Omega::just_pressed(Gosu::KB_RETURN) then
            $sounds["validate"].play();
            @exit = true
        end

        
        if @timer >= MAX_TIMER or @exit

            if @current_slide == 2 or @exit
                if not Omega.is_transition?
                    transition = Omega::FadeTransition.new(10, Omega::Color::copy(Omega::Color::WHITE)) do
                        Omega.set_state(MenuState.new)
                    end
                    Omega.launch_transition(transition)
                    return
                end
            else
                @alpha = (@alpha + 5).clamp(0, 255)

                if @alpha == 255
                    @timer = 0
                    @current_slide += 1
                end
            end
        else
            @alpha = (@alpha - 5).clamp(0, 255)
        end

        @timer += 1
    end

    def draw
        @bg[@current_slide].y = 40
        @bg[@current_slide].draw

        @text.text = @desc[@current_slide]
        @text.x = (Omega.width - @text.width) / 2
        @text.y = Omega.height - @text.height - 20
        @text.draw()

        Gosu.draw_rect(0, 0, Omega.width, Omega.height, Gosu::Color.new(@alpha, 0, 0, 0), 1000)
    end

end
