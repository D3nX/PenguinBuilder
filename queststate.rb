class QuestState < Omega::State

    def load_background
        @quest_background = Omega::Sprite.new("assets/quest_background.png")
    end

    def load_map
        @isomap = IsoMap.new("assets/ctileset.png", 80, 80)
        @isomap.load_csv_layer("assets/maps/quests/quest_#{$quest}/quest_#{$quest}_layer_0.csv")
        @isomap.load_csv_layer("assets/maps/quests/quest_#{$quest}/quest_#{$quest}_layer_1.csv")
        @isomap.load_csv_layer("assets/maps/quests/quest_#{$quest}/quest_#{$quest}_layer_2.csv")

        @ressources = @isomap.get_ressource_list
    end

    def load_camera
        @camera = Omega::Camera.new(false)
        s = (7.0 / @isomap.width) * 2
        @camera.scale = Omega::Vector2.new(s, s)
    end

    def load_text
        @text = Omega::Text.new("", Gosu::Font.new(60))
    end

    def load
        load_background()
        load_map()
        load_camera()
        load_text()
    end

    def update
        if Omega::just_pressed(Gosu::KB_RETURN)
            $quest += 1
            $quest %= 4
            $quest = 1 if $quest == 0
            Omega.set_state(QuestState.new)
            return
        end
    end

    def draw
        @quest_background.draw

        @camera.draw do
            scale = @camera.scale.x
            center_map_x = (Omega.width / scale - @isomap.width * IsoMap::TILE_WIDTH) / 2

            @isomap.position = Omega::Vector3.new(center_map_x - 400 / scale, 450 / scale, 0)
            @isomap.margin = 200 / scale
            @isomap.draw

            @isomap.position = Omega::Vector3.new(center_map_x, 280 / scale, 0)
            @isomap.margin = 0
            @isomap.draw
        end
        draw_ui()
    end

    def draw_ui
        x = Omega.width - 300
        y = Omega.height - 400

        @text.scale = Omega::Vector2.new(0.5, 0.5)

        @ressources.each do |k, v|
            if v > 0
                @text.text = "#{k}: #{$inventory[k]} / #{v}"
                @text.x = x
                @text.y = y
                @text.color = Omega::Color::copy(Omega::Color::BLACK)
                @text.draw()

                @text.x += 2
                @text.y += 2
                @text.color = Omega::Color::copy(Omega::Color::WHITE)
                @text.draw
            
                y += @text.height + 5
            end
        end

        @text.text = "Ressources\n   needed:"
        @text.y -= (@text.height + 5) * 2 + 15
        @text.color = Omega::Color::copy(Omega::Color::BLACK)
        @text.draw

        @text.x += 2
        @text.y += 2
        @text.color = Omega::Color.new(255, 230, 0)
        @text.draw

        # Title
        @text.scale = Omega::Vector2.new(1.5, 1.5)
        @text.text = "Quest #{$quest}"
        @text.x = (Omega.width - @text.width) / 2
        @text.y = 30
        @text.color = Omega::Color::copy(Omega::Color::BLACK)
        @text.draw

        @text.x += 2
        @text.y += 2
        @text.color = Omega::Color.new(255, 240, 200)
        @text.draw

        # Quest name
        @text.scale = Omega::Vector2.new(1, 1)
        @text.text = $quest_name[$quest - 1]
        @text.color = Omega::Color::copy(Omega::Color::BLACK)
        @text.x = (Omega.width - @text.width) / 2
        @text.y = Omega.height - @text.height - 50
        @text.draw

        @text.x += 2
        @text.y += 2
        @text.color = Omega::Color.new(255, 240, 200)
        @text.draw
    end

end
