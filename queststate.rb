class QuestState < Omega::State

    attr_accessor :finished

    def load_background
        @quest_background = Omega::Sprite.new("assets/quest_background.png")
    end

    def load_map
        @isomap = $quests_maps[$quest - 1]

        @available = $quest_status[$quest_status.keys()[$quest - 1]]["available"]
        @isomap.color = Omega::Color::copy(Omega::Color::WHITE)
        @isomap.color = Omega::Color::copy(Omega::Color::BLACK) if not @available
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

        @finished = false
    end

    def update
        if Omega::just_pressed(Gosu::KB_RETURN)
            $quest += 1
            $quest %= 4
            $quest = 1 if $quest == 0
            load()
            return
        elsif Omega::just_pressed(Gosu::KB_F1)
            @finished = true
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
                @text.text = "#{k}: #{$inventory[k]} / #{(@available) ? v : "???"}"
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

        # Quest Status
        status = $quest_status[$quest_status.keys()[$quest - 1]]["done"]
        @text.text = "Quest status:\n#{(status) ? " " * 6 + "Done" : " " * 4 + "Undone"}"
        @text.y += 50
        @text.color = Omega::Color::copy(Omega::Color::BLACK)
        @text.draw

        @text.text = "Quest status:\n#{(status) ? " " * 6 + "Done" : " " * 4 + "Undone"}"
        @text.x += 2
        @text.y += 2
        @text.color = (status) ? Omega::Color.new(64, 255, 64) : Omega::Color.new(255, 32, 32)
        @text.draw

        # Ressources text
        @text.text = "Ressources\n   needed:"
        @text.y -= (@text.height + 5) * 2 + 65
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
        @text.text = (@available) ? $quest_status.keys()[$quest - 1] + " (#{@isomap.width}x#{@isomap.height})" : "???"
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
