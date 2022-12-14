class QuestState < Omega::State

    attr_accessor :finished

    def load_background
        @quest_background = Omega::Sprite.new("assets/quest_background.png")
    end

    def load_map
        @isomap = $quests_maps[@c_quest - 1]

        @available = $quest_status[$quest_status.keys()[@c_quest - 1]]["available"]
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
        @text = Omega::Text.new("", $font)
    end

    def load(reset_c_quest = true, is_hero = false)
        @c_quest = $quest if reset_c_quest
        @finished = false
        @is_hero = is_hero
        @inventory = $inventory
        @inventory = $hero_inventory if is_hero
        @margin = 150

        load_background()
        load_map()
        load_camera()
        load_text()
    end

    def update
        if Omega::just_pressed(Gosu::KB_RIGHT)
            @c_quest += 1
            @c_quest %= ($quests_maps.size + 1)
            @c_quest = 1 if @c_quest == 0
            $sounds["select"].play()
            load(false)
            return
        elsif Omega::just_pressed(Gosu::KB_LEFT)
            @c_quest -= 1
            @c_quest %= $quests_maps.size
            @c_quest = $quests_maps.size if @c_quest == 0
            $sounds["select"].play()
            load(false)
            return
        elsif Omega::just_pressed(Gosu::KB_ESCAPE)
            @finished = true
            $sounds["cancel"].play()
        end

        if Omega::pressed(Gosu::KB_DOWN)
            @margin -= 5 if @margin > 0
        elsif Omega::pressed(Gosu::KB_UP)
            @margin += 5 if @margin < 300
        end
    end

    def draw
        @quest_background.draw

        @camera.draw do
            scale = @camera.scale.x
            is_on_side = ($rotation == 1 or $rotation == 3) ? 1 : 0
            center_map_x = (Omega.width / scale - ((is_on_side == 1) ? @isomap.height : @isomap.width) * IsoMap::TILE_WIDTH) / 2
            
            @isomap.rotation = $rotation

            add_x = is_on_side * (@isomap.pixel_height + 40)
            add_y = -is_on_side * (@isomap.pixel_width + 45)

            @isomap.position = Omega::Vector3.new(center_map_x - 400 / scale + add_x, 450 / scale + add_y, 0)
            @isomap.margin = @margin / scale
            @isomap.draw

            @isomap.position = Omega::Vector3.new(center_map_x + add_y + is_on_side * 15, 280 / scale + add_x - is_on_side * 25, 0)
            @isomap.margin = 0
            @isomap.draw
        end
        draw_ui()
        draw_controls()
    end

    def draw_ui
        x = Omega.width - 300
        y = Omega.height - 400

        @text.scale = Omega::Vector2.new(0.5, 0.5)

        materials = 0

        i = 0
        @ressources.each do |k, v|
            if v > 0 and k != "Grass"
                exploration_inventory = (@is_hero) ? $hero_inventory[k] : 0
                materials += 1
                @text.text = "#{(@available) ? k : "???"}: #{(@available) ? "#{$inventory[k] + exploration_inventory}" : "???"} / #{(@available) ? v : "???"}"
                @text.x = x
                @text.y = y
                @text.color = Omega::Color::copy(Omega::Color::BLACK)
                @text.draw()

                @text.x += 2
                @text.y += 2
                @text.color = Omega::Color::copy(Omega::Color::WHITE)
                @text.draw
            
                y += @text.height + 5
                i += 1
            end
        end

        if i == 2
            y -= (@text.height + 5) * 2
            @text.y = y
        end

        # Quest Status
        status = $quest_status[$quest_status.keys()[@c_quest - 1]]["done"]
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
        @text.y -= (@text.height + 5) * (materials - 1) + 65
        @text.color = Omega::Color::copy(Omega::Color::BLACK)
        @text.draw

        @text.x += 2
        @text.y += 2
        @text.color = Omega::Color.new(255, 230, 0)
        @text.draw

        # Title
        @text.scale = Omega::Vector2.new(1.5, 1.5)
        @text.text = "Quest #{@c_quest}"
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
        @text.text = (@available) ? $quest_status.keys()[@c_quest - 1] + " (#{@isomap.width}x#{@isomap.height})" : "???"
        @text.color = Omega::Color::copy(Omega::Color::BLACK)
        @text.x = (Omega.width - @text.width) / 2
        @text.y = Omega.height - @text.height - 50
        @text.z = 100_000
        @text.draw

        @text.x += 2
        @text.y += 2
        @text.color = Omega::Color.new(255, 240, 200)
        @text.draw
    end

    def draw_controls
        @text.scale = Omega::Vector2.new(0.5, 0.5)
        @text.text = "Controls:\nRight / Left: Change quest\nUp / Down: Move layers\nESC: Go back"
        @text.x = Omega.width - @text.width - 2
        @text.y = Omega.height - @text.height - 7
        @text.z -= 1000
        @text.color = Omega::Color::copy(Omega::Color::BLACK)
        @text.draw

        @text.x -= 2
        @text.y -= 2
        @text.color = Omega::Color::copy(Omega::Color::WHITE)
        @text.draw
    end

end
