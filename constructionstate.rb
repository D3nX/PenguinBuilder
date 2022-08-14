class ConstructionState < Omega::State

    def load_map
        @isomap = IsoMap.new("assets/ctileset.png", 18, 10)
=begin
        w, h = 3, 4
        for y in 0...h
            for x in 0...w
                if (x == 0 or x == w - 1) or (y == h - 1)
                    @isomap.push_block(5 + x, 7, IsoMap::Block::STONE)
                else
                    @isomap.push_block(5 + x, 7, -1)
                end
            end
        end
=end
    end

    def load_camera
        @camera = Omega::Camera.new(false)
        @camera.scale = Omega::Vector2.new(3, 3)
    end

    def load_cursor
        @cursor = Cursor.new(@isomap, @camera)
        @camera.follow(@cursor, 0.5)
    end

    def load
        load_map()
        load_camera()
        load_cursor()
    end

    def update
        @cursor.update
    end

    def draw
        @camera.draw do
            @isomap.draw
            @cursor.draw
        end
        @cursor.draw_hud
    end

end
