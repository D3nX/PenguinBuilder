class WorldMapState < Omega::State

    def load
        @map_sprite = Omega::Sprite.new("assets/worldmap.png")
        @map_sprite.x = (Omega.width - @map_sprite.width) / 2
        @map_sprite.y = (Omega.height - @map_sprite.height) / 2

        @map_cursor = Omega::Sprite.new("assets/map_cursor.png")
        @map_cursor.set_scale(3)
        @map_cursor.set_origin(0, 1.0)

        @places_point = [
            Omega::Vector2.new(400, 230),
            Omega::Vector2.new(460, 413),
            Omega::Vector2.new(710, 250),
            Omega::Vector2.new(950, 340),
        ]
        @current_place = 0

        $musics["world_map"].play(true)
    end

    def update
        @map_cursor.x -= (@map_cursor.x - @places_point[@current_place].x) * 0.1
        @map_cursor.y -= (@map_cursor.y - @places_point[@current_place].y) * 0.1

        if Omega::just_pressed(Gosu::KB_RIGHT)
            @current_place += 1
            @current_place %= @places_point.size
        elsif Omega::just_pressed(Gosu::KB_LEFT)
            @current_place -= 1
            @current_place %= @places_point.size
        elsif Omega::just_pressed(Gosu::KB_RETURN)
            if Omega::just_pressed(Gosu::KB_X) or Omega::just_pressed(Gosu::KB_RETURN)
                if not Omega.is_transition?
                    transition = Omega::FadeTransition.new(10, Omega::Color::copy(Omega::Color::BLACK)) do
                        if @current_place == 2
                            Omega.set_state($construction_state)
                        else
                            $current_map = "desert" if @current_place == 0
                            $current_map = "castle" if @current_place == 1
                            $current_map = "forest" if @current_place == 3
                            Omega.set_state(ExplorationState.new)
                        end
                    end
                    Omega.launch_transition(transition)
                    return
                end
            end
        end
    end

    def draw
        Gosu.draw_rect(0, 0, Omega.width, Omega.height, Gosu::Color.new(64, 64, 64), 0)
        @map_sprite.draw()
        @map_cursor.draw()
    end

end
