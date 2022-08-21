class ConstructionState < Omega::State

    def load_map
        @isomap = IsoMap.new("assets/ctileset.png", 25, 25)

        quest_nb = 3

        # @isomap.load_csv_layer("assets/maps/quests/quest_#{quest_nb}/quest_#{quest_nb}_layer_0.csv")
        # @isomap.load_csv_layer("assets/maps/quests/quest_#{quest_nb}/quest_#{quest_nb}_layer_1.csv")
        # @isomap.load_csv_layer("assets/maps/quests/quest_#{quest_nb}/quest_#{quest_nb}_layer_2.csv")

        # @isomap.enable_debug_tile(true)
        @isomap.generate_empty_map()

        # w, h = 3, 4
        # for y in 0...h
        #     for x in 0...w
        #         @isomap.push_block(5 + x, 7, IsoMap::Block::STONE)
        #         if y == 0
        #             for d in 0..2
        #                 @isomap.push_block(5 + x, 7 + d, IsoMap::Block::STONE)
        #             end
        #         end
        #     end
        # end
    end

    def load_camera
        @camera = Omega::Camera.new(false)
        @camera.scale = Omega::Vector2.new(3, 3)
    end

    def load_cursor
        @notification = Notification.new()
        @notification.launch(["Hi, just a little tip:", "If the quest doesn't ask you grass tiles as a base,", "feel free to dig them!"], 150)
        
        @cursor = Cursor.new(@isomap, @camera, @notification)
        @camera.follow(@cursor, 0.5)
    end

    def load_ui
        @item_menu = ItemMenu.new(@isomap, @cursor)
        @text = Omega::Text.new("", Omega::DefaultFont)
    end

    def load
        load_map()
        load_camera()
        load_cursor()
        load_ui()

        @substate = nil
    end

    def update
        if @substate
            @substate.update
            @substate = nil if @substate.finished
            return
        end
        @cursor.update

        if Omega::just_pressed(Gosu::KB_F1)
            @substate = QuestState.new
            @substate.load
        end
    end

    def draw
        if @substate
            @substate.draw
            return
        end

        @camera.draw do
            @isomap.draw
            @cursor.draw
        end
        draw_ui
    end

    def draw_ui
        @item_menu.draw

        # Text orientation
        @text.scale = Omega::Vector2.new(0.25, 0.25)
        @text.text = "Orientation: #{IsoMap::RotationString[@isomap.rotation]}"
        @text.x = (Omega.width - @text.width - 290)
        @text.y = (Omega.height - 125)
        @text.z = 1000
        @text.color = Omega::Color::copy(Omega::Color::BLACK)
        @text.draw

        @text.x -= 2
        @text.y -= 2
        @text.color = Omega::Color::copy(Omega::Color::WHITE)
        @text.draw

        # Text item
        @text.scale = Omega::Vector2.new(0.25, 0.25)
        @text.text = "Item: #{@cursor.get_item_name}"
        @text.x = 290
        @text.y = (Omega.height - 125)
        @text.z = 1000
        @text.color = Omega::Color::copy(Omega::Color::BLACK)
        @text.draw

        @text.x -= 2
        @text.y -= 2
        @text.color = Omega::Color::copy(Omega::Color::WHITE)
        @text.draw

        draw_controls()

        @notification.draw
    end

    def draw_controls
        @text.scale = Omega::Vector2.new(0.15, 0.15)
        @text.text = "Controls:\nF1: Check quests\nTab: Change item\nX / C: Place / Erase\nB / N: Rise / Lower cursor\nArrow keys: Move\nEnter / Backspace: Rotate"
        @text.x = Omega.width - @text.width - 2
        @text.y = Omega.height - @text.height - 7
        @text.color = Omega::Color::copy(Omega::Color::BLACK)
        @text.draw

        @text.x -= 2
        @text.y -= 2
        @text.color = Omega::Color::copy(Omega::Color::WHITE)
        @text.draw
    end

end
