class BackToVillageState < Omega::State

    HERO_BASE_SCALE = 4;
    TIMER_ADD_LOOT = 0.06;
    ICON_SPEED = 16;
    FLASH_SPEED = 3
    FADE_SPEED = 3;

    def load
        load_hero();
        load_village();

        @text = Omega::Text.new("Resources obtained: " + 0.to_s, $font);

        @timer_add_loot = TIMER_ADD_LOOT;

        @list_icons = [];
        @list_keys = get_keys_inventory();
        @current_key_index = 0;
        @can_fade = false;
        
        @alpha_fade = 0;
        @alpha_flash = 255;
        @quantity_item = 0;

        transfer_to_main_inventory();
    end

    def update
        update_alpha_flash();
        return if (@alpha_flash > 0)

        if (!@can_fade) then
            update_timer();
        else
            update_alpha_fade() if (@list_icons.length <= 0)
        end

        update_list_icons();

        if (@village.scale.x > HERO_BASE_SCALE) then
            @village.scale.x = @village.scale.y -= 0.05;

            @village.scale = Omega::Vector2.new(HERO_BASE_SCALE,HERO_BASE_SCALE) if (@village.scale.x <= HERO_BASE_SCALE)
        end

    end

    def draw
        @hero.draw

        for i in 0...@list_icons.length do
            @list_icons[i].draw();
        end

        @village.draw

        @text.draw_at_pos(Omega::Text::WindowPos::MIDDLEDOWN,0,0)

        Gosu.draw_rect(0, 0, Omega.width, Omega.height, Gosu::Color.new(@alpha_flash,0,0,0))
        Gosu.draw_rect(0, 0, Omega.width, Omega.height, Gosu::Color.new(@alpha_fade,0,0,0))

    end

    def load_hero()
        @hero = Omega::SpriteSheet.new("assets/hero.png", 16, 24);
        @hero.add_animation("DIE", [0]);
        @hero.play_animation("DIE");
        @hero.scale.x = @hero.scale.y = HERO_BASE_SCALE;
        @hero.origin.x = @hero.origin.y = 0.5;
        @hero.position = Omega::Vector3.new(Omega.width*0.8, Omega.height*0.5, 0);
    end

    def load_village()
        @village = Omega::Sprite.new("assets/village.png");
        @village.scale.x = @village.scale.y = HERO_BASE_SCALE;
        @village.origin.x = @village.origin.y = 0.5;
        @village.position = Omega::Vector3.new(Omega.width*0.2, Omega.height*0.5, 0);
    end

    def get_keys_inventory()
        list_keys = []
        $inventory.keys().each do |k|
            list_keys.push(k.to_s);
        end
        return list_keys
    end

    def spawn_icon(resource)
        icon = LootIcon.new(resource);
        icon.velocity.x = -ICON_SPEED;
        icon.origin = @hero.origin;
        icon.scale = Omega::Vector2.new(HERO_BASE_SCALE-1,HERO_BASE_SCALE-1);
        icon.position = @hero.position.clone;
        $sounds["validate"].play();

        @list_icons.push(icon)
        @quantity_item += 1;
        @text.text = "Resources obtained: " + @quantity_item.to_s;
    end

    def remove_from_hero_inventory(resource, quantity)
        $hero_inventory[resource] -= quantity;
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
                Omega.set_state(WorldMapState.new)
            end
        end
    end

    def update_list_icons()
        for i in 0...@list_icons.length do
            return if (@list_icons[i] == nil)

            @list_icons[i].update() 

            if (@list_icons[i].position.x <= Omega.width*0.18) then
                @list_icons.delete_at(i) 
                @village.scale.x = @village.scale.y = HERO_BASE_SCALE + 0.4;
            end
        end
    end

    def update_timer()
        @timer_add_loot -= 0.01

        if (@timer_add_loot < 0) then
            current_resource = @list_keys[@current_key_index]

            if ($hero_inventory[current_resource] <= 0) then
                @current_key_index += 1;

                if (@current_key_index >= @list_keys.length) then
                    @current_key_index = @list_keys.length
                    @can_fade = true; 
                end
            else
                spawn_icon(current_resource);
                remove_from_hero_inventory(current_resource, 1);
            end

            @timer_add_loot = TIMER_ADD_LOOT;
        end
    end

    def transfer_to_main_inventory()
        $inventory.keys().each do |k|
            $inventory[k] += $hero_inventory[k];
        end
    end

end
