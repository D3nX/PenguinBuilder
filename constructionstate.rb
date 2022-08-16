class ConstructionState < Omega::State

    def load_map
        @isomap = IsoMap.new("assets/ctileset.png", 80, 80)

        @isomap.load_csv_layer("assets/maps/test_map_layer_0.csv")
        @isomap.load_csv_layer("assets/maps/test_map_layer_1.csv")
        # @isomap.generate_empty_map()

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
        @cursor = Cursor.new(@isomap, @camera)
        @camera.follow(@cursor, 0.5)
    end

    def load_ui
        @item_menu = ItemMenu.new(@isomap, @cursor)

        @text = Omega::Text.new("Orientation", Omega::DefaultFont)
        @text.scale = Omega::Vector2.new(0.25, 0.25)
    end

    def load
        load_map()
        load_camera()
        load_cursor()
        load_ui()
    end

    def update
        @cursor.update
    end

    def draw
        @camera.draw do
            @isomap.draw
            @cursor.draw
        end
        draw_ui
    end

    def draw_ui
        @item_menu.draw

        @text.text = "Orientation: #{IsoMap::RotationString[@isomap.rotation]}"
        @text.x = (Omega.width - @text.width) / 2
        @text.y = (Omega.height - 125)
        @text.z = 1000
        @text.draw
    end

end
