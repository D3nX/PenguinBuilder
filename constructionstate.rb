class ConstructionState < Omega::State

    def load_map
        @isomap = IsoMap.new("assets/ctileset.png", 18, 10)

        w, h = 3, 4
        for y in 0...h
            for x in 0...w
                @isomap.push_block(5 + x, 7, IsoMap::Block::STONE)
                if y == 0
                    for d in 0..2
                        @isomap.push_block(5 + x, 7 + d, IsoMap::Block::STONE)
                    end
                end
            end
        end
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
