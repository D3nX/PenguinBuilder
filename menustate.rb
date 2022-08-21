class MenuState < Omega::State

    def load
        @bg = Omega::Sprite.new("assets/cutscenes/slide_2.png")
        @title = Omega::Text.new("", Gosu::Font.new(60, name: "assets/Perfect_DOS_VGA.ttf"))
        @titlescreen_bar = Omega::Sprite.new("assets/titlescreen_bar.png")

        @title_ty = -@title.height

        $musics["title_screen"].play(true)
    end

    def update
        if Omega::just_pressed(Gosu::KB_X) or Omega::just_pressed(Gosu::KB_RETURN)
            if not Omega.is_transition?
                transition = Omega::FadeTransition.new(10, Omega::Color::copy(Omega::Color::BLACK)) do
                    Omega.set_state(ExplorationState.new)
                end
                Omega.launch_transition(transition)
                return
            end
        end
    end

    def draw
        @bg.y = (Omega.height - @bg.height) / 2
        @bg.draw()

        @titlescreen_bar.y = 0
        @titlescreen_bar.draw()

        @titlescreen_bar.y = Omega.height - @titlescreen_bar.height
        @titlescreen_bar.draw()

        @title.set_scale(1)
        @title.text = "Penguin Builder"
        @title.x = (Omega.width - @title.width) / 2 + 50
        @title_ty += 5 if @title_ty < 20
        @title.y = @title_ty
        @title.color = Omega::Color.new(255, 255, 32)
        @title.draw

        time = 800
        if Gosu.milliseconds % time < time / 2
            @title.set_scale(0.7)
            @title.text = "Press X to play"
            @title.x = (Omega.width - @title.width) / 2 + 50
            @title.y = (Omega.height - @title.height) - 20
            @title.color = Omega::Color::copy(Omega::Color::WHITE)
            @title.draw
        end
    end

end
