class Monster < Omega::SpriteSheet

    TIMER_INVINCIBILTY = 1.2

    TIMER_BLINK = 0.5

    def initialize(hero, camera, path, width, height, hp, damage)
        super(path,width,height)
        @hero = hero;
        @camera = camera;
        @hp_max = hp.clone;

        @hitbox = Omega::Rectangle.new(0,0,1,1);
        @hitbox_offset = Omega::Rectangle.new(0,0,0,0);

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

        @alpha = 255;
    end

    def update()
        update_velocity();
        update_damage() if (!@can_take_damage)
        update_hitbox();

        if (@hero.is_attacking) then
            if (@hitbox.collides?(@hero.hitbox_pickaxe)) then receive_damage(@hero.attack);
            end
        end

        if (!@is_dead && !@hero.is_attacking && @can_take_damage && @hitbox.collides?(@hero.hitbox)) then
            @hero.receive_damage(@damage);
        end

        update_death() if (@is_dead && !@death_animation_is_finished)

    end

    def draw()
        super() if (!@death_animation_is_finished)
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

    def update_damage()
        play_animation("HIT")

        @color = Gosu::Color::RED;
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

    def receive_damage(damage) 
        return if (@is_dead || !@can_take_damage)

        @hp -= damage;

        $sounds["hit_monster"].play() if (@hp > 0)
            
        @scale.x = @base_scale.x + 0.2;
        @scale.y = @base_scale.y + 0.2;
        @camera.shake(12,-0.5,0.5);

        if (@hp <= 0) then
            if (!@is_dead) then
                $sounds["monster_die"].play();
                # spawn loot here
                @is_dead = true 
            end
        end

        @can_take_damage = false;
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
        for i in 0..loot_quantity
            resource_to_obtain = rand(list_of_items[0]..list_of_items.length)
            if (rand(0,100) <= loot_probability) then
                loot = Loot.new(resource_to_obtain);
                @list_items.push(loot);
            end
        end
    end

end