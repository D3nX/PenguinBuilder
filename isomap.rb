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
        WOOD  = 4
        GLASS = 5
    end

    BlockNames = [
        "Grass",
        "Stone",
        "Sand",
        "Water",
        "Wood",
        "Glass"
    ]

    RotationString = [
        "North",
        "West",
        "South",
        "East"
    ]

    class IsoTile
        attr_accessor :id, :offset_scale, :rect

        def initialize(id, offset_scale, rect)
            @id = id
            @offset_scale = offset_scale.to_f
            @rect = rect
        end
    end

    Light = Struct.new(:x, :y, :z, :power)
    
    attr_reader :tileset, :width, :height
    attr_accessor :rotation, :light

    def initialize(tileset_path, width, height)
        @tileset = Gosu::Image.load_tiles(tileset_path, TILE_WIDTH, TILE_HEIGHT, :tileable => true)
        @width = width
        @height = height
        @rotation = 0
        @light = Light.new(0, 0, 0, 1.8)
        @draw_debug_tile = false

        @blocks = Array.new(height) { Array.new(width) { [] } }
    end

    def generate_empty_map
        @blocks = Array.new(height) { Array.new(width) { [IsoTile.new(0, 1)] } }
    end

    def load_csv_layer(path, offset_scale = 1)
        data = File.read(path)
        x, y = 0, 0
        nwidth, nheight = data.split("\n")[0].split(",").size, data.split("\n").size

        if nwidth != @width or nheight != @height
            @width = nwidth
            @height = nheight
            @blocks = Array.new(@height) { Array.new(@width) { [] } }
        end

        data.split("\n").each do |line|
            line.split(",").each do |id|
                push_block(x, y, id.to_i, offset_scale) if id.to_i != -1
                x += 1
            end
            x = 0
            y += 1
        end
    end

    def tile_at(x, y, z)
        if y < @blocks.size and x < @blocks[y].size and z < @blocks[y][x].size
            return @blocks[y][x][z]
        end
        return nil
    end

    def push_block(x, y, id, offset_scale = 0)
        if @blocks[y][x].size < Z_OFFSET
            z = @blocks[y][x].size
            @blocks[y][x] << IsoTile.new(id, offset_scale, Omega::Rectangle.new(x * TILE_WIDTH, y * TILE_WIDTH - z * Z_OFFSET, TILE_WIDTH, TILE_WIDTH))
            return true
        else
            puts("Cannot put any more blocks!")
        end
        return false
    end

    def pop_block(x, y)
        if @blocks[y][x].size > 0
            block = @blocks[y][x].pop

            while @blocks[y][x].size > 0 and @blocks[y][x].last.id == -1
                @blocks[y][x].pop
            end
            return block
        else
            puts("No block left!")
        end
        return nil
    end

    def height_of(x, y)
        return @blocks[y][x].size * (TILE_HEIGHT - Z_OFFSET)
    end

    def enable_debug_tile(enable)
        @draw_debug_tile = enable
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
                    c = 0
                    if @rotation == 0 or @rotation == 2
                        c = Omega::distance3d(@light, Omega::Vector3.new(x, y, base_z_offset / Z_OFFSET)) / @light.power
                    else
                        c = Omega::distance3d(@light, Omega::Vector3.new(y, x, base_z_offset / Z_OFFSET)) / @light.power
                    end
                    c = c.clamp(0, 255)
                    fx = x
                    fy = y
                    fx, fy = fy, fx if @rotation == 1 or @rotation == 3
                    if tile.id >= 0 and tile.id < @tileset.size
                        @tileset[tile.id].draw(fx, fy - base_z_offset * tile.offset_scale, 0, 1, 1, Gosu::Color.new(255, 255 - c, 255 - c, 255 - c))
                        if @draw_debug_tile
                            tile.rect.z = 1000
                            tile.rect.color.alpha = 128
                            tile.rect.draw
                        end
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
