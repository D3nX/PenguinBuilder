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

        if Omega::just_pressed(Gosu::KB_RETURN)
            last_rotation = @isomap.rotation
            @isomap.rotation += 1
            @isomap.rotation %= 4

            if last_rotation == 0 and @isomap.rotation == 1
                puts("0::1!")
                @tile_position.x = @isomap.height - @tile_position.x - 1
            end

            @position.x = @tile_position.x * IsoMap::TILE_WIDTH
            @position.y = @tile_position.y * (IsoMap::TILE_HEIGHT - IsoMap::Z_OFFSET)
            @camera.follow(self, 1.0)

            puts @position

            puts "changing angle: #{@isomap.rotation}"
        end

        if Omega::just_pressed(Gosu::KB_X)
            tpos = @tile_position.clone
            tpos.x, tpos.y = tpos.y, @isomap.height - tpos.x - 1 if @isomap.rotation == 1
            tpos.x, tpos.y = @isomap.width - tpos.x - 1, @isomap.height - tpos.y - 1 if @isomap.rotation == 2
            tpos.x, tpos.y = @isomap.width - tpos.y - 1, tpos.x if @isomap.rotation == 3

            if @isomap.push_block(tpos.x, tpos.y, @block_id)
                @push.play()
            end
        elsif Omega::just_pressed(Gosu::KB_C)
            tpos = @tile_position.clone
            tpos.x, tpos.y = tpos.y, @isomap.height - tpos.x - 1 if @isomap.rotation == 1
            tpos.x, tpos.y = @isomap.width - tpos.x - 1, @isomap.height - tpos.y - 1 if @isomap.rotation == 2
            tpos.x, tpos.y = @isomap.width - tpos.y - 1, tpos.x if @isomap.rotation == 3

            if @isomap.pop_block(tpos.x, tpos.y)
                @pop.play()
            end
        end

        if Omega::just_pressed(Gosu::KB_TAB)
            @block_id += 1
            @block_id %= 4
        end
    end

    def draw
        # map_width = @isomap.width
        # map_height = @isomap.height
        # map_width, map_height = map_height, map_width if @isomap.rotation == 1 or @isomap.rotation == 3

        # @tile_position.x = @tile_position.x.clamp(0, map_width - 1)
        # @tile_position.y = @tile_position.y.clamp(0, map_height - 1)

        @position.x -= (@position.x - @tile_position.x * IsoMap::TILE_WIDTH) * 0.5
        @position.y -= (@position.y - @tile_position.y * (IsoMap::TILE_HEIGHT - IsoMap::Z_OFFSET)) * 0.5
        super()
        @camera.follow(self, 0.5) if @lerp != 0.5
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
        map_width = @isomap.width
        map_height = @isomap.height
        map_width, map_height = map_height, map_width if @isomap.rotation == 1 or @isomap.rotation == 3
        if tpos.x >= 0 and tpos.y >= 0 and
            tpos.x < map_width and tpos.y < map_height
            set_tile_position(tpos)
        end
    end

end
