class Monster < Omega::SpriteSheet

    TIMER_INVINCIBILTY = 1.2

    TIMER_BLINK = 0.5

    UI_Z = 100_000

    HUD_THICKNESS = 4;

    attr_reader :death_animation_is_finished, :name, :can_draw_hud

    def initialize(hero, camera, map, path, width, height, hp, damage)
        super(path,width,height)
        @name = "";

        @hero = hero;
        @camera = camera;
        @hp_max = hp.clone;

        @map = map;

        @hitbox = Omega::Rectangle.new(0,0,1,1);
        @hitbox_offset = Omega::Rectangle.new(0,0,0,0);
        @can_draw_hitbox = true;

        @has_collide = false;
        @alpha = 255;

        @hp = hp;
        @damage = damage;

        @base_scale = @scale.clone;
        @is_dead = false;
        @can_take_damage = false;

        @origin = Omega::Vector2.new(0.5,0.5);
        @velocity = Omega::Vector2.new(0,0);
        @timer_invicibility = 0;
        @timer_blink = TIMER_BLINK;
        @death_animation_is_finished = false;
        @blink_nb = 0;

        @list_text_damage = []

        @alpha = 255;

        @is_invincible = false;
        @can_draw_hud = false;
    end

    def update()
        update_velocity();
        update_damage_animation() if (!@can_take_damage)
        update_hitbox();
        update_z_order();

        check_damage() if (!@is_dead)

        update_text_damage() if (@list_text_damage.length > 0)

        update_death() if (@is_dead && !@death_animation_is_finished)

        

        for i in 0...@list_items.length do
            next if (@list_items[i] == nil) 

            @list_items[i].update() 
            @list_items.delete_at(i) if (@list_items[i].is_collected)
        end
    end

    def draw()
        super() if (!@death_animation_is_finished)

        draw_text_damage() if (@list_text_damage.length > 0)

        for i in 0...@list_items.length do
            @list_items[i].draw();
        end
    end

    def update_velocity()
        @position.x += @velocity.x;
        @position.y += @velocity.y;
    end

    def update_hitbox() 
        @hitbox.position.x = @position.x-(@width*@scale.x*@origin.x) + @hitbox_offset.position.x;
        @hitbox.position.y = @position.y-(@height*@scale.y*@origin.y) + @hitbox_offset.position.y;
        @hitbox.width = @width*@scale.x + @hitbox_offset.width;
        @hitbox.height = @height*@scale.y + @hitbox_offset.height;
    end

    def update_damage_animation()
        play_animation("HIT")

        @color = Gosu::Color::GRAY;
        @timer_invicibility -= 0.1;
        @scale.x -= 0.04;
        @scale.y -= 0.04;

        if (@timer_invicibility < 0) then
            @color = Gosu::Color::WHITE;
            @can_take_damage = true;
            @scale = @base_scale.clone;
            play_animation("IDLE");
            @timer_invicibility = TIMER_INVINCIBILTY;
        end
    end

    def check_damage()
        if (@hero.is_attacking && @hitbox.collides?(@hero.hitbox_pickaxe)) then receive_damage(@hero.generate_attack()) end

            for i in 0...@hero.list_bricks.length do
                if (@hero.list_bricks[i] != nil && @hitbox.collides?(@hero.list_bricks[i].hitbox)) then 
                    damage = @hero.generate_attack() + (@hero.generate_attack()*0.5)
                    receive_damage(damage) 
                    @hero.list_bricks.delete_at(i);
                end
            end
    
            if (!@hero.is_attacking && @can_take_damage && @hitbox.collides?(@hero.hitbox) && @damage > 0) then
                 @hero.receive_damage(@damage);
            end
    end

    def receive_damage(damage) 
        return if (@is_dead || !@can_take_damage)

        damage = 0 if (@is_invincible)

        @hp -= damage;

        @list_text_damage.push(TextDamage.new(damage,Omega::Vector3.new(@position.x - 4, @position.y, UI_Z), 0.3));

        $sounds["hit_monster"].play() if (@hp > 0)
            
        @scale.x = @base_scale.x + 0.2;
        @scale.y = @base_scale.y + 0.2;
        @camera.shake(12,-0.5,0.5);

        if (@hp <= 0) then
            if (!@is_dead) then
                $sounds["monster_die"].play();
                spawn_loot();
                @is_dead = true 
            end
        end

        @can_take_damage = false;
    end

    def update_text_damage()
        for i in 0...@list_text_damage.length
            next if (@list_text_damage[i] == nil)

            @list_text_damage[i].update();
            @list_text_damage.delete_at(i) if (@list_text_damage[i].alpha <= 0)
        end
    end

    def update_death()
        play_animation("DIE") if (@current_animation != "DIE")

        @timer_blink -= 0.1;
        @color = Gosu::Color.new(@alpha, @color.red, @color.green, @color.blue);

        @scale.x -= 0.01
        @scale.y -= 0.02

        @scale.x = 0 if (@scale.x <= 0)
        @scale.y = 0 if (@scale.y <= 0) 

        if (@timer_blink < 0) then
            @blink_nb += 1;
            @alpha = (@alpha >= 160) ?  50 : 160
            @timer_blink = (@blink_nb%2 == 0) ? TIMER_BLINK*2 : TIMER_BLINK;
        end

        if (@blink_nb >= 20) then
            @death_animation_is_finished = true;
            @list_text_damage = [];
        end
    end

    def update_z_order()
        @position.z = 100 + @position.y
    end

    def draw_text_damage()
        for i in 0...@list_text_damage.length
            @list_text_damage[i].draw();
        end
    end

    # Give all informations about the loot of a specific monster
    # And also set default array @list_items to store the visible items when a monster die
    def set_loot(quantity, list_of_resources, probability_to_drop)
        @loot_quantity = quantity;
        @list_resources_droppable = list_of_resources;
        @loot_probability = probability_to_drop;

        @list_items = []
    end

    # Use this function when monster die to define which items will spawn
    def spawn_loot()
        for i in 0..@loot_quantity
            random_item_index = rand(0...@list_resources_droppable.length)
            resource_to_obtain = @list_resources_droppable[random_item_index]
            if (rand(0..100) <= @loot_probability) then
                loot = Loot.new(@hero, resource_to_obtain);
                loot.position = @position.clone;
                range = 2;
                loot.velocity = Omega::Vector2.new(rand(-range..range),rand(-range..range));
                
                @list_items.push(loot);
                loot = nil;
            end
        end
    end

    def draw_life()
        pos_x = Omega.width*0.2
        pos_y = Omega.height*0.9
        width = Omega.width*0.6
        height = 26;

        Gosu.draw_rect(pos_x - HUD_THICKNESS, pos_y - HUD_THICKNESS, width + (2*HUD_THICKNESS), height + (2*HUD_THICKNESS), Gosu::Color.new(255,255,255,255), UI_Z)
        Gosu.draw_rect(pos_x, pos_y, (@hp * width)/@hp_max, height, Gosu::Color.new(255, 255, 0,0), UI_Z);
        $font.draw_text(@name.to_s, pos_x + 12, pos_y + height*0.5 - 14, UI_Z+10, 0.6, 0.6, Gosu::Color::BLACK);
    end


    # From here, it's all about collision detection with terrain.
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