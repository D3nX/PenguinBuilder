class IsoMap

    TILE_WIDTH = 16
    TILE_HEIGHT = 24
    Z_OFFSET = 8
    MAX_Z_HEIGHT = 10

    module Block
        GRASS = 0
        STONE = 1
        SAND  = 2
        WATER = 3
    end

    class IsoTile
        attr_accessor :id, :offset_scale

        def initialize(id, offset_scale)
            @id = id
            @offset_scale = offset_scale.to_f
        end
    end
    
    attr_reader :tileset, :width, :height
    attr_accessor :rotation

    def initialize(tileset_path, width, height)
        @tileset = Gosu::Image.load_tiles(tileset_path, TILE_WIDTH, TILE_HEIGHT)
        @width = width
        @height = height
        @rotation = 0

        @blocks = Array.new(height) { Array.new(width) { [IsoTile.new(0, 1)] } }
    end

    def push_block(x, y, id, offset_scale = 0)
        if @blocks[y][x].size < Z_OFFSET
            @blocks[y][x] << IsoTile.new(id, offset_scale)
            return true
        else
            puts("Cannot put any more blocks!")
        end
        return false
    end

    def pop_block(x, y)
        if @blocks[y][x].size > 0
            @blocks[y][x].pop

            while @blocks[y][x].size > 0 and @blocks[y][x].last.id == -1
                @blocks[y][x].pop
            end
            return true
        else
            puts("No block left!")
        end
        return false
    end

    def height_of(x, y)
        return @blocks[y][x].size * (TILE_HEIGHT - Z_OFFSET)
    end

    def draw
        x, y = 0, 0

        local_blocks = @blocks.clone
        local_blocks = local_blocks.reverse if (@rotation == 1 or @rotation == 2) and @rotation != 3

        local_blocks.each do |cols|
            columns = cols
            columns = cols.reverse if @rotation == 2 or @rotation == 3
            columns.each do |z_columns|
                base_z_offset = 0
                for tile in z_columns
                    c = base_z_offset
                    fx = x
                    fy = y
                    fx, fy = fy, fx if @rotation == 1 or @rotation == 3
                    if tile.id >= 0 and tile.id < @tileset.size
                        @tileset[tile.id].draw(fx, fy - base_z_offset * tile.offset_scale, 0, 1, 1, Gosu::Color.new(255, 255 - c, 255 - c, 255 - c))
                        tile.offset_scale -= (tile.offset_scale - 1.0) * 0.1
                    end
                    base_z_offset += Z_OFFSET
                end
                x += TILE_WIDTH
            end
            x = 0
            y += TILE_HEIGHT - Z_OFFSET
        end
    end

end
