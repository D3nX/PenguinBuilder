class Cursor < Omega::Sprite

    attr_reader :block_id

    UI_Z = 100_000

    def initialize(isomap, camera, notification)
        super("assets/cursor.png")

        @isomap = isomap
        @camera = camera
        @notification = notification
        @block_id = 0
        @tile_position = Omega::Vector2.new(0, 0)
        @offset = 0
        @sound = nil
    end

    def check_ressources
        if Omega::just_pressed(Gosu::KB_Q) or
            Omega::just_pressed(Gosu::KB_SPACE) or Omega::just_pressed(Gosu::KB_E) or
            Omega::just_pressed(Gosu::KB_X) or Omega::just_pressed(Gosu::KB_C)
            if @isomap.has_ressources?($quests_maps[$quest - 1])
                # puts "has enough ressources"
                if @isomap.has_construction?($quests_maps[$quest - 1])
                    # puts "and it match!"
                    name = $quest_status.keys()[$quest - 1]
                    if not $quest_status[name]["done"]
                        $quest_status[name]["done"] = true

                        if $quest < $quests_maps.size
                            $quest += 1
            
                            name = $quest_status.keys()[$quest - 1]
                            $quest_status[name]["available"] = true
                            $sounds["quest_finished"].play()
                            @notification.launch(["Quest accomplished!", "You are now stronger", "Press ESCAPE to check for the next quest!"])
                        else
                            @sound = $sounds["quest_finished"].play()
                            @notification.launch(["Quest accomplished!",
                                                    "Congratulation, you finished all the quests.",
                                                    "Thank you very much for playing!",
                                                    "Feel free to build anything from now on!"])
                        end
                    end
                else
                    # puts "but not match yet..."
                end
            end
        end

        $musics["victory"].play(true) if @sound and not @sound.playing?
    end

    def update
        move(1, 0) if Omega::just_pressed(Gosu::KB_D) or Omega::just_pressed(Gosu::KB_RIGHT)
        move(-1, 0) if Omega::just_pressed(Gosu::KB_A) or Omega::just_pressed(Gosu::KB_LEFT)
        move(0, 1) if Omega::just_pressed(Gosu::KB_S) or Omega::just_pressed(Gosu::KB_DOWN)
        move(0, -1) if Omega::just_pressed(Gosu::KB_W) or Omega::just_pressed(Gosu::KB_UP)

        pressed_enter = Omega::just_pressed(Gosu::KB_RETURN)
        pressed_backspace = Omega::just_pressed(Gosu::KB_BACKSPACE)

        @offset = (@isomap.height_of(@tile_position.x, @tile_position.y) - IsoMap::Z_OFFSET)

        if pressed_enter or pressed_backspace
            last_rotation = @isomap.rotation
            @isomap.rotation += (Omega::just_pressed(Gosu::KB_RETURN)) ? 1 : -1
            @isomap.rotation %= 4

            if @isomap.rotation == 0
                if pressed_enter
                    @tile_position.x, @tile_position.y = @isomap.width - @tile_position.y - 1, @tile_position.x
                else
                    @tile_position.x, @tile_position.y = @tile_position.y, @isomap.height - @tile_position.x - 1
                end
            end

            if @isomap.rotation == 1
                if pressed_enter
                    @tile_position.x, @tile_position.y = @isomap.height - @tile_position.y - 1, @tile_position.x
                else
                    @tile_position.x, @tile_position.y = @tile_position.y, @isomap.width - @tile_position.x - 1
                end
            end

            if @isomap.rotation == 2
                if pressed_enter
                    @tile_position.x, @tile_position.y = @isomap.width - @tile_position.y - 1, @tile_position.x
                else
                    @tile_position.x, @tile_position.y = @tile_position.y, @isomap.height - @tile_position.x - 1
                end
            end

            if @isomap.rotation == 3
                if pressed_enter
                    @tile_position.x, @tile_position.y = @isomap.height - @tile_position.y - 1, @tile_position.x
                else
                    @tile_position.x, @tile_position.y = @tile_position.y, @isomap.width - @tile_position.x - 1
                end
            end

            @position.x = @tile_position.x * IsoMap::TILE_WIDTH
            @position.y = @tile_position.y * (IsoMap::TILE_HEIGHT - IsoMap::Z_OFFSET) - @offset
            @camera.follow(self, 1.0)
        end

        place_invisible_block = false # Omega::just_pressed(Gosu::KB_B)
        erase_invisible_block = false # Omega::just_pressed(Gosu::KB_N)
        if Omega::just_pressed(Gosu::KB_SPACE) or Omega::just_pressed(Gosu::KB_Q) or Omega::just_pressed(Gosu::KB_X) or place_invisible_block
            tpos = @tile_position.clone
            tpos.x, tpos.y = tpos.y, @isomap.height - tpos.x - 1 if @isomap.rotation == 1
            tpos.x, tpos.y = @isomap.width - tpos.x - 1, @isomap.height - tpos.y - 1 if @isomap.rotation == 2
            tpos.x, tpos.y = @isomap.width - tpos.y - 1, tpos.x if @isomap.rotation == 3

            block = @block_id
            block = -1 if place_invisible_block

            if (place_invisible_block or $inventory[IsoMap::BlockNames[@block_id]] > 0) and @isomap.push_block(tpos.x, tpos.y, block)
                if not place_invisible_block
                    $sounds["put_block"].play()
                    $inventory[IsoMap::BlockNames[@block_id]] -= 1
                end
            else
                $sounds["empty"].play();
                @camera.shake(16,-0.6,0.6);
            end
        elsif Omega::just_pressed(Gosu::KB_E) or Omega::just_pressed(Gosu::KB_C) or erase_invisible_block
            tpos = @tile_position.clone
            tpos.x, tpos.y = tpos.y, @isomap.height - tpos.x - 1 if @isomap.rotation == 1
            tpos.x, tpos.y = @isomap.width - tpos.x - 1, @isomap.height - tpos.y - 1 if @isomap.rotation == 2
            tpos.x, tpos.y = @isomap.width - tpos.y - 1, tpos.x if @isomap.rotation == 3

            popped = @isomap.pop_block(tpos.x, tpos.y, erase_invisible_block)
            if popped and !erase_invisible_block
                $sounds["remove_block"].play()
                $inventory[IsoMap::BlockNames[popped.id]] += 1
            end
        end

        # if Omega::just_pressed(Gosu::KB_LEFT) or Omega::just_pressed(Gosu::KB_RIGHT)
        #     @block_id += (Omega::just_pressed(Gosu::KB_RIGHT)) ? 1 : -1
        #     @block_id %= IsoMap::BlockNames.size
        #     $sounds["select"].play()
        # end


        for i in 1..9
            if eval("Omega::just_pressed(Gosu::KB_#{i})")
                $sounds["select"].play()
                @block_id = i - 1
                break
            end
        end

        @isomap.light = nil
        # @isomap.light.x = @position.x
        # @isomap.light.y = @position.y
        check_ressources()
    end

    def draw
        # map_width = @isomap.width
        # map_height = @isomap.height
        # map_width, map_height = map_height, map_width if @isomap.rotation == 1 or @isomap.rotation == 3

        # @tile_position.x = @tile_position.x.clamp(0, map_width - 1)
        # @tile_position.y = @tile_position.y.clamp(0, map_height - 1)
    
        @position.x -= (@position.x - @tile_position.x * IsoMap::TILE_WIDTH) * 0.5
        @position.y -= (@position.y - (@tile_position.y * (IsoMap::TILE_HEIGHT - IsoMap::Z_OFFSET) - @offset)) * 0.5
        @position.z = UI_Z
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
        pile = @isomap.pile_at(@tile_position.x, @tile_position.y)
        if pile and pile.size > 0 && pile.last.id == -1
            @isomap.pop_block(@tile_position.x, @tile_position.y)
        end
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

        $sounds["move_cursor"].play(1.0,rand(1.0..1.5));
    end

    def get_item_name
        return IsoMap::BlockNames[@block_id]
    end

end
