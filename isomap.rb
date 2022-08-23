class IsoMap

    TILE_WIDTH = 16
    TILE_HEIGHT = 24
    Z_OFFSET = 8
    MAX_Z_HEIGHT = 10

    module Block
        GRASS   = 0
        STONE   = 1
        SAND    = 2
        WATER   = 3
        WOOD    = 4
        GLASS   = 5
        DIRT    = 6
        CACTUS  = 7
        BUSH    = 8
    end

    module Rotation
        NORTH   = 0
        WEST    = 1
        SOUTH   = 2
        EAST    = 3
    end

    NO_BORDERS = [
        Block::GLASS, Block::BUSH
    ]

    BlockNames = [
        "Grass",
        "Stone",
        "Sand",
        "Water",
        "Wood",
        "Glass",
        "Dirt",
        "Cactus",
        "Bush"
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
        @@border_tileset ||= Gosu::Image.load_tiles("assets/tile_borders.png", TILE_WIDTH, TILE_WIDTH, :tileable => true)
        @@border_front_tileset ||= Gosu::Image.load_tiles("assets/tile_front.png", TILE_WIDTH, Z_OFFSET, :tileable => true)
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

    def tile_at(x, y, z = nil)
        if x >= 0 and y >= 0 and y < @blocks.size and x < @blocks[y].size
            pile = pile_at(x, y)
            z = pile - 1 if pile and not z
            if pile and z >= 0 and z < pile.size
                return pile[z]
            end
        end
        return nil
    end

    def push_block(x, y, id, offset_scale = 0)
        if @blocks[y][x].size < Z_OFFSET
            z = @blocks[y][x].size
            
            @blocks[y][x] << IsoTile.new(id, z, offset_scale, Omega::Rectangle.new(x * TILE_WIDTH, y * TILE_WIDTH - z * Z_OFFSET, TILE_WIDTH, TILE_WIDTH))
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
                        screen_y = fy - base_z_offset * tile.offset_scale - i * @margin
                        @tileset[tile.id].draw(fx, screen_y, screen_y + i * 100, 1, 1,
                                                Gosu::Color.new(@color.alpha, @color.red - c, @color.green - c, @color.blue - c))
                        if @draw_debug_tile
                            tile.rect.z = screen_y + i * 100 + 10000
                            tile.rect.color.alpha = 128
                            tile.rect.draw
                        end
                        draw_border(tile, x / TILE_WIDTH, y / (TILE_HEIGHT - Z_OFFSET), fx, screen_y, screen_y + i * 100)
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

    def draw_border(tile, x, y, draw_x, draw_y, draw_z)
        return if NO_BORDERS.include?(tile.id)

        if @rotation == 1 or @rotation == 3
            x, y = y, x
        end

        someone_above = tile_at(x, y, tile.z + 1)
        someone_under = (tile_at(x, y, tile.z - 1) != nil) && (tile_at(x, y + 1, tile.z - 1) == nil)


        is_right        = tile_at(x + 1, y, tile.z)
        is_right        = false if is_right and NO_BORDERS.include?(is_right.id)

        is_left         = tile_at(x - 1, y, tile.z)
        is_left         = false if is_left and NO_BORDERS.include?(is_left.id)

        is_up           = tile_at(x, y - 1, tile.z)
        is_up           = false if is_up and NO_BORDERS.include?(is_up.id)

        is_down         = tile_at(x, y + 1, tile.z)
        is_down         = false if is_down and NO_BORDERS.include?(is_down.id)

        if not someone_above
            if not is_right
                @@border_tileset[0].draw(draw_x, draw_y, draw_z)
            end

            if not is_left
                @@border_tileset[1].draw(draw_x, draw_y, draw_z)
            end
            
            if not is_down
                @@border_tileset[2].draw(draw_x, draw_y, draw_z)
                draw_front(draw_x, draw_y, draw_z, is_left, is_right, someone_under)
            end

            if not is_up
                @@border_tileset[3].draw(draw_x, draw_y, draw_z)
            end
        else
            draw_front(draw_x, draw_y, draw_z, is_left, is_right, someone_under)
        end
    end

    def draw_front(draw_x, draw_y, draw_z, is_left, is_right, someone_under)
        @@border_front_tileset[0].draw(draw_x, draw_y + TILE_HEIGHT - Z_OFFSET, draw_z) if not someone_under
        @@border_front_tileset[1].draw(draw_x, draw_y + TILE_HEIGHT - Z_OFFSET, draw_z) if not is_left
        @@border_front_tileset[2].draw(draw_x, draw_y + TILE_HEIGHT - Z_OFFSET, draw_z) if not is_right
    end

    def get_ressource_list
        ressources = {
            "Grass" => 0,
            "Stone" => 0,
            "Sand" => 0,
            "Water" => 0,
            "Wood" => 0,
            "Glass" => 0,
            "Dirt" => 0,
            "Cactus" => 0,
            "Bush" => 0
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
