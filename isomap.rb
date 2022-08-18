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
        DIRT  = 6
    end

    module Rotation
        NORTH   = 0
        WEST    = 1
        SOUTH   = 2
        EAST    = 3
    end

    BlockNames = [
        "Grass",
        "Stone",
        "Sand",
        "Water",
        "Wood",
        "Glass",
        "Dirt"
    ]

    RotationString = [
        "North",
        "West",
        "South",
        "East"
    ]

    class IsoTile
        attr_accessor :id, :z, :offset_scale, :rect

        def initialize(id, z, offset_scale, rect)
            @id = id
            @z = z
            @offset_scale = offset_scale.to_f
            @rect = rect
        end
    end

    Light = Struct.new(:x, :y, :z, :power)
    
    attr_reader :tileset, :width, :height, :blocks
    attr_accessor :position, :rotation, :light, :margin, :color

    def initialize(tileset_path, width, height)
        @tileset = Gosu::Image.load_tiles(tileset_path, TILE_WIDTH, TILE_HEIGHT, :tileable => true)
        @width = width
        @height = height
        @rotation = 0
        @light = Light.new(0, 0, 0, 1.8)
        @draw_debug_tile = false
        @margin = 0
        @position = Omega::Vector3.new(0, 0, 0)
        @color = Omega::Color::copy(Omega::Color::WHITE)

        @blocks = Array.new(height) { Array.new(width) { [] } }
    end

    def generate_empty_map
        @blocks = Array.new(height) { Array.new(width) { [] } }
        for x in 0...width
            for y in 0...height
                push_block(x, y, Block::GRASS, 1)
            end
        end
    end

    def load_csv_layer(path, offset_scale = 1.0)
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

    def tile_at(x, y, z = -1)
        if y < @blocks.size and x < @blocks[y].size and z < @blocks[y][x].size
            return @blocks[y][x][z]
        end
        return nil
    end

    def push_block(x, y, id, offset_scale = 0)
        if @blocks[y][x].size < Z_OFFSET
            z = @blocks[y][x].size
            @blocks[y][x] << IsoTile.new(id, offset_scale, z, Omega::Rectangle.new(x * TILE_WIDTH, y * TILE_WIDTH - z * Z_OFFSET, TILE_WIDTH, TILE_WIDTH))
            return true
        else
            puts("Cannot put any more blocks!")
        end
        return false
    end

    def pop_block(x, y, erase_invisible_block = false)
        if @blocks[y][x].size > 0
            block = @blocks[y][x].pop if !erase_invisible_block or @blocks[y][x][-1].id == -1

            while @blocks[y][x].size > 0 and @blocks[y][x].last.id == -1 and !erase_invisible_block
                @blocks[y][x].pop
            end
            return block
        else
            puts("No block left!")
        end
        return nil
    end

    def height_of(x, y)
        case @rotation
        when 0
            return @blocks[y][x].size * Z_OFFSET
        when 1
            return @blocks[@height - x - 1][y].size * Z_OFFSET
        when 2
            return @blocks[@height - y - 1][@width - x - 1].size * Z_OFFSET
        else # 3
            return @blocks[x][@width - y - 1].size * Z_OFFSET
        end

        return 0
    end

    def pile_at(x, y)
        case @rotation
        when 0
            return @blocks[y][x]
        when 1
            return @blocks[@height - x - 1][y]
        when 2
            return @blocks[@height - y - 1][@width - x - 1]
        else # 3
            return @blocks[x][@width - y - 1]
        end

        return nil
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
                for i in 0...z_columns.size
                    tile = z_columns[i]
                    c = 0
                    if @light
                        if @rotation == 0 or @rotation == 2
                            c = Omega::distance3d(@light, Omega::Vector3.new(x, y, base_z_offset / Z_OFFSET)) / @light.power
                        else
                            c = Omega::distance3d(@light, Omega::Vector3.new(y, x, base_z_offset / Z_OFFSET)) / @light.power
                        end
                    end
                    c = c.clamp(0, 255)
                    fx = x + @position.x
                    fy = y + @position.y
                    fx, fy = fy, fx if @rotation == 1 or @rotation == 3
                    if tile.id >= 0 and tile.id < @tileset.size
                        @tileset[tile.id].draw(fx, fy - base_z_offset * tile.offset_scale - i * @margin, 0, 1, 1,
                                                Gosu::Color.new(@color.alpha, @color.red - c, @color.green - c, @color.blue - c))
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

    def get_ressource_list
        ressources = {
            "Grass" => 0,
            "Stone" => 0,
            "Sand" => 0,
            "Water" => 0,
            "Wood" => 0,
            "Glass" => 0,
            "Dirt" => 0
        }

        @blocks.each do |cols|
            cols.each do |z_columns|
                for tile in z_columns
                    ressources[BlockNames[tile.id]] += 1 if tile.id != -1
                end
            end
        end
        return ressources
    end

    def has_ressources?(other_map)
        ressources = get_ressource_list()
        other_res = other_map.get_ressource_list()

        ressources.each do |k, v|
            return false if v < other_res[k]
        end
        return true
    end

    # Construction checking

    def has_construction?(other_map)
        return false if other_map.width > @width
        return false if other_map.height > @height

        # Generating id for current map
        blocks_ids = Array.new(@height) { Array.new(@width) { [] } }

        for y in 0...@blocks.size
            for x in 0...@blocks[y].size
                for t in @blocks[y][x]
                    blocks_ids[y][x] << t.id
                end
            end
        end
        
        # Generating id for other map
        other_blocks_ids = Array.new(other_map.height) { Array.new(other_map.width) { [] } }
        
        for y in 0...other_map.blocks.size
            for x in 0...other_map.blocks[y].size
                for t in other_map.blocks[y][x]
                    other_blocks_ids[y][x] << t.id
                end
            end
        end

        # Check if some where it matches

        for y in 0...blocks_ids.size
            for x in 0...blocks_ids.size
                if check_correspondance_at(x, y, blocks_ids, other_blocks_ids)
                    return true
                end
            end
        end

        return false

        # for y in 0...blocks_ids.size
        #     for x in 0...blocks_ids[y].size

        #     end
        # end
    end

    private

    def check_correspondance_at(x, y, blocks_ids, other_blocks_ids)
        for oby in 0...other_blocks_ids.size
            for obx in 0...other_blocks_ids[oby].size
                if blocks_ids[y + oby][x + obx] != other_blocks_ids[oby][obx]
                    return false
                end
            end
        end
        return true
    end


end
