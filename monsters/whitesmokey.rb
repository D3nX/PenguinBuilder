class WhiteSmokey < Monster

    TIMER_DIRECTION = 0.05;
    TIMER_WAIT = 0.4;
    SPEED = 8;

    MUSIC_DISTANCE_DETECTION = 160

    def initialize(hero, camera, map)
        super(hero, camera, "assets/smokey.png", 30, 30, 640, 11)
        set_loot(36,["Water", "Sand", "Mana"], 75)

        @name = "Dark Smokey"
        @map = map;

        @base_scale = Omega::Vector2.new(2.5,2.5);
        @scale = @base_scale.clone;

        # Every monsters have to possess a HIT and DIE animation
        add_animation("IDLE", [0]);

        add_animation("DOWN", [0,1,2,1]);
        add_animation("TOP", [3,4,5,4]);
        add_animation("HIT", [6]);
        add_animation("DIE", [6]);

        @velocity.y = SPEED;
        play_animation("DOWN")

        @timer_direction = TIMER_DIRECTION;
        @timer_wait = TIMER_WAIT;

        @hitbox_offset = Omega::Rectangle.new(5*@base_scale.x,8*@base_scale.x,-10*@base_scale.y,-14*@base_scale.y);
    end

    def update()
        update_music_detection();

        super()

        @timer_direction -= 0.01

        if (!@can_take_damage || @hp <= 0 || Omega.distance(@hero.position, @position) > 300) then
            @velocity.x = @velocity.y = 0;
            return
        end

        if (@timer_direction < 0) then
            @velocity.x = @velocity.y = 0;

            @timer_wait -= 0.01;

            if (@timer_wait < 0) then
                choose_random_direction();
                @timer_direction = TIMER_DIRECTION;
                @timer_wait = TIMER_WAIT;
            end
        end

        update_collision_with_map();

    end

    def draw()
        super()
    end

    def choose_random_direction()
        horizontal_or_vertical = rand(0..1)

        if (horizontal_or_vertical == 0) then
            # Horizontal
            @velocity.x = (rand(0..1) == 0) ? SPEED : -SPEED;
        else
            # Vertical
            @velocity.y = (rand(0..1) == 0) ? SPEED : -SPEED;

            play_animation("TOP") if (@current_animation != "TOP" && @velocity.y < 0)
            play_animation("DOWN") if (@current_animation != "DOWN" && @velocity.y > 0)

            
        end
    end

    def update_music_detection()
        @can_draw_hud = @boss_music_is_launch;

        if (!@boss_music_is_launch && Omega.distance(@hero.position, @position) <= MUSIC_DISTANCE_DETECTION) then

            $musics[$current_map].volume -= 0.02;

            if ($musics[$current_map].volume <= 0) then
                $musics["boss"].play(true);
                $musics["boss"].volume = 1.0
                @boss_music_is_launch = true;
            end
        end

        if (@hp <= 0 || (@boss_music_is_launch && Omega.distance(@hero.position, @position) > MUSIC_DISTANCE_DETECTION)) then
            $musics["boss"].volume -= 0.02;

            if ($musics["boss"].volume <= 0) then
                $musics[$current_map].play(true);
                $musics[$current_map].volume = 1.0
                @boss_music_is_launch = false;
            end
        end

        if (@hp > 0 && @boss_music_is_launch && Omega.distance(@hero.position, @position) <= MUSIC_DISTANCE_DETECTION && $musics["boss"].volume < 1.0) then
            $musics["boss"].volume += 0.2
            $musics["boss"].volume = 1.0 if ($musics["boss"].volume >= 1.0)
        end
    end

    def update_collision_with_map()
        solid_tiles = [3]; # add here other solid tiles that need collision on **LAYER 0**
        tile_size = IsoMap::TILE_WIDTH;

        for z in 0..1 do
            # Collision top
            tile1 = @map.tile_at((@hitbox.x+2)/tile_size, (@hitbox.y-2)/tile_size, z)
            tile2 = @map.tile_at((@hitbox.x+@hitbox.width-2)/tile_size, (@hitbox.y-2)/tile_size, z)

            if @velocity.y < 0 && check_collision(tile1, tile2, z, solid_tiles) then 
                @velocity.y = 0; 
            end 

            # Collision right
            tile1 = @map.tile_at((@hitbox.x + @hitbox.width + 2)/tile_size, (@hitbox.y + 2)/tile_size, z)
            tile2 = @map.tile_at((@hitbox.x + @hitbox.width + 2)/tile_size, (@hitbox.y + @hitbox.height - 2)/tile_size, z)

            if @velocity.x > 0 && check_collision(tile1, tile2, z, solid_tiles) then 
                @velocity.x = 0; 
            end 

            # Collision left
            tile1 = @map.tile_at((@hitbox.x - 2)/tile_size, (@hitbox.y + 2)/tile_size, z)
            tile2 = @map.tile_at((@hitbox.x - 2)/tile_size, (@hitbox.y + @hitbox.height - 2)/tile_size, z)

            if @velocity.x < 0 && check_collision(tile1, tile2, z, solid_tiles) then 
                @velocity.x = 0; 
            end 

            # Collision bottom
            tile1 = @map.tile_at((@hitbox.x + 2)/tile_size, (@hitbox.y + @hitbox.height + 2)/tile_size, z)
            tile2 = @map.tile_at((@hitbox.x+@hitbox.width-2)/tile_size, (@hitbox.y + @hitbox.height + 2)/tile_size, z)

            if @velocity.y > 0 && check_collision(tile1, tile2, z, solid_tiles) then 
                @velocity.y = 0; 
            end 
            
        end
    end

    def check_if_tile_is_solid(list_solid_tiles, tile_to_check)
        for i in 0...list_solid_tiles.length do
            if (tile_to_check == list_solid_tiles[i]) then
                return true;
            end
        end
        return false;
    end

    def check_collision(tile1, tile2, z, solid_tiles)
        return (tile1 != nil && check_if_tile_is_solid(solid_tiles, tile1.id)) || (tile2 != nil && check_if_tile_is_solid(solid_tiles, tile2.id)) || ((z != 0 && tile1 != nil) || (z != 0 && tile2 != nil))
    end

end