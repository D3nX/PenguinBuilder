class GameOverState < Omega::State

    PERCENTAGE_TO_LOOSE = 75
    TIMER_LOOSE_RESOURCE = 0.05
    PROJECTION_FORCE = 15;
    HERO_BASE_SCALE = 4;
    GRAVITY = 0.5
    FLASH_SPEED = 3
    FADE_SPEED = 3;

    def load
        load_hero();

        @text = Omega::Text.new("NB Resource lost: " + 0.to_s, $font);

        @list_loot_icon_to_loose = [];
        @alpha_fade = 0;
        @alpha_flash = 255;

        @timer_loose_resource = TIMER_LOOSE_RESOURCE;

        @nb_elements_in_inventory = count_nb_resource_in_inventory()
        @nb_resource_to_loose = ((@nb_elements_in_inventory*PERCENTAGE_TO_LOOSE)/100).to_i;
    end

    def update
        update_alpha_flash();
        return if (@alpha_flash > 0)

        update_alpha_fade() if (@nb_resource_to_loose <= 0)

        update_timer_resource();

        if (@hero.scale.x >= HERO_BASE_SCALE) then
            @hero.scale.x = @hero.scale.y -= 0.1
            @hero.scale = Omega::Vector2.new(HERO_BASE_SCALE,HERO_BASE_SCALE) if (@hero.scale.x <= HERO_BASE_SCALE)
        end

        for i in 0...@list_loot_icon_to_loose.length do
            @list_loot_icon_to_loose[i].update();
            @list_loot_icon_to_loose[i].velocity.y += GRAVITY;
        end
    end

    def draw
        @hero.draw();
        @text.draw_at_pos(Omega::Text::WindowPos::MIDDLEDOWN,0,0)
        @text.position.z = 0;

        for i in 0...@list_loot_icon_to_loose.length do
            @list_loot_icon_to_loose[i].draw();
        end

        Gosu.draw_rect(0, 0, Omega.width, Omega.height, Gosu::Color.new(@alpha_flash,255,0,0))
        Gosu.draw_rect(0, 0, Omega.width, Omega.height, Gosu::Color.new(@alpha_fade,0,0,0))
    end

    def load_hero()
        @hero = Omega::SpriteSheet.new("assets/hero.png", 16, 24);
        @hero.add_animation("DIE", [16]);
        @hero.play_animation("DIE");
        @hero.scale.x = @hero.scale.y = HERO_BASE_SCALE;
        @hero.origin.x = @hero.origin.y = 0.5;
        @hero.position = Omega::Vector3.new(Omega.width*0.5, Omega.height*0.5, 0);
    end

    def count_nb_resource_in_inventory()
        sum = 0;
        $hero_inventory.keys().each do |k| sum += $hero_inventory[k] end
        return sum;
    end

    def select_random_resource()
        list_of_elements = []

        $hero_inventory.keys().each do |k|
            list_of_elements.push(k)
        end

        random_value = rand(0...list_of_elements.length-1); # We don't want to draw MANA
        return list_of_elements[random_value];
    end

    def delete_resource(resource, quantity)
        $hero_inventory[resource] -= ($hero_inventory[resource] <= 0) ? 0 : quantity;
    end

    def spawn_icon(resource)
        return if ($hero_inventory[resource] > 0)
        icon = LootIcon.new(resource);
        icon.velocity = Omega::Vector2.new(rand(-PROJECTION_FORCE..PROJECTION_FORCE), rand(-PROJECTION_FORCE..0));
        icon.origin = @hero.origin;
        icon.scale = Omega::Vector2.new(HERO_BASE_SCALE-1,HERO_BASE_SCALE-1);
        icon.position = @hero.position.clone;
        @list_loot_icon_to_loose.push(icon)
        @text.text = "Resources lost: " + @list_loot_icon_to_loose.length.to_s
    end

    def update_timer_resource()
        @timer_loose_resource -= 0.01

        if (@timer_loose_resource < 0) then
            if (@nb_resource_to_loose > 0) then
                random_resource = select_random_resource()
                quantity_before_removal = $hero_inventory[random_resource];
                delete_resource(random_resource, 1);
                spawn_icon(random_resource);
                
                if (quantity_before_removal > 0)
                    @hero.scale = Omega::Vector2.new(HERO_BASE_SCALE+1,HERO_BASE_SCALE+1) 
                    $sounds["cancel"].play()
                end
                @nb_resource_to_loose -= 1; 
            end
            @timer_loose_resource = TIMER_LOOSE_RESOURCE;
        end
    end

    def update_alpha_flash()
        if (@alpha_flash > 0) then
            @alpha_flash -= FLASH_SPEED;

            if (@alpha_flash <= 0) then
                @alpha_flash = 0;
           end
        end
    end

    def update_alpha_fade()
        if (@alpha_fade < 255) then
            @alpha_fade += FADE_SPEED;
            if (@alpha_fade >= 255) then
                @alpha_fade = 255;
                transfer_to_main_inventory();
                Omega.set_state(ConstructionState.new)
            end
        end
    end

    def transfer_to_main_inventory()
        $inventory.keys().each do |k|
            $inventory[k] += $hero_inventory[k];
        end
    end

end