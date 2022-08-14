class Cursor < Omega::Sprite

    def initialize(isomap, camera)
        super("assets/cursor.png")

        @push = Gosu::Sample.new("assets/push.wav")
        @pop = Gosu::Sample.new("assets/pop.wav")
        @isomap = isomap
        @camera = camera
        @block_id = IsoMap::Block::STONE
        @tile_position = Omega::Vector2.new(0, 0)
    end

    def update
        move(1, 0) if Omega::just_pressed(Gosu::KB_RIGHT)
        move(-1, 0) if Omega::just_pressed(Gosu::KB_LEFT)
        move(0, 1) if Omega::just_pressed(Gosu::KB_DOWN)
        move(0, -1) if Omega::just_pressed(Gosu::KB_UP)

        if Omega::just_pressed(Gosu::KB_X)
            if @isomap.push_block(@tile_position.x, @tile_position.y, @block_id)
                @push.play()
            end
        elsif Omega::just_pressed(Gosu::KB_C)
            if @isomap.pop_block(@tile_position.x, @tile_position.y)
                @pop.play()
            end
        end

        if Omega::just_pressed(Gosu::KB_TAB)
            @block_id += 1
            @block_id %= 4
        end
    end

    def draw
        @position.x -= (@position.x - @tile_position.x * IsoMap::TILE_WIDTH) * 0.5
        @position.y -= (@position.y - @tile_position.y * (IsoMap::TILE_HEIGHT - IsoMap::Z_OFFSET)) * 0.5
        super()
    end

    def draw_hud
        scale = 4
        Gosu.draw_rect(0, 0, (IsoMap::TILE_WIDTH + 10) * scale, (IsoMap::TILE_HEIGHT + 10) * scale, Gosu::Color.new(240, 240, 240), 1000)
        @isomap.tileset[@block_id].draw(5 * scale, 5 * scale, 1000, scale, scale)
    end

    def set_tile_position(tpos)
        @tile_position = tpos
    end

    def move(offset_x, offset_y)
        tpos = @tile_position.clone
        tpos.x += offset_x
        tpos.y += offset_y
        if tpos.x >= 0 and tpos.y >= 0 and
            tpos.x < @isomap.width and tpos.y < @isomap.height
            set_tile_position(tpos)
        end
    end

end
