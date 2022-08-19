class Hero < Omega::SpriteSheet

    # Constants Player
    SPEED = 2;
    SPEED_PICKAXE = 15;
    PICKAXE_ANGLE_RANGE = 150;
    ATTACK_AMPLITUDE_VARIATION = 0.2
    TIMER_INVINCIBILTY = 2.5
    TIMER_WAIT_BEFORE_REFILL_ENERGY = 1.2
    ENERGY_COST = 4;
    MP_COST = 3;

    # Constants Interfaces :
    HUD_WIDTH_HP = 220;
    HUD_WIDTH_MP = 180;
    HUD_WIDTH_ENERGY = 140;
    HUD_ENERGY_BLINK_FREQUENCY = 0.04
    HUD_THICKNESS = 4;
    DEFAULT_BAG_SCALE = 2;
    

    attr_reader :hitbox, :hitbox_pickaxe, :attack, :hp, :hp_max, :mp, :mp_max, :is_attacking, :list_bricks, :bag_resources
    attr_accessor :velocity;

    def initialize(cam)
        super("assets/hero.png",16,24);
        @origin = Omega::Vector2.new(0.5,0.5);

        load_statistics();
        load_hud_elements();

        load_animation();
        play_animation("top");

        @camera = cam;
        
        @hitbox = Omega::Rectangle.new(0,0,1,1);
        @velocity = Omega::Vector2.new(0,0);

        @timer_invicibility = TIMER_INVINCIBILTY

        load_pickaxe();

        @is_attacking = false;
        @can_take_damage = true;
        @is_dead = false;
        @can_draw_hitbox = false;

        @list_bricks = [];
        @list_loot_info = [];
    end

    def update()
        update_velocity();
        update_hitbox();
        update_inputs();
        update_damage() if (!@can_take_damage)
        update_pickaxe() if (@is_attacking)
        update_energy();

        for i in 0...list_bricks.length do
            list_bricks[i].update();
        end
        
    end

    def draw()
        super();
        @pickaxe.draw() if @is_attacking

        for i in 0...list_bricks.length do
            list_bricks[i].draw();
        end

        # DEBUG
        @hitbox.draw if (@can_draw_hitbox)
        @hitbox_pickaxe.draw if (@can_draw_hitbox)
    end

    def collect_resource(resource)
        case resource
        when "Grass", "Stone", "Sand", "Water", "Wood", "Glass"
            $hero_inventory[resource] += 1;
            loot_info = LootInfo.new(resource, Omega::Vector3.new(12, Omega.height - 12, 0));
            @list_loot_info.push(loot_info)
            @icon_bag.scale = Omega::Vector2.new(DEFAULT_BAG_SCALE + 2, DEFAULT_BAG_SCALE + 2);
        when "Mana"
            @mp += 5;
            @mp = @mp_max if (@mp >= @mp_max)
        end
    end

    def receive_damage(damage) 
        if (@can_take_damage) then
            $sounds["hit_hero"].play();
            @timer_invicibility = TIMER_INVINCIBILTY;
            @hp -= damage;
            @camera.shake(16,-1,1);
            @is_dead = true if (@hp <= 0)
            @can_take_damage = false;
        end
    end

    def generate_attack()
        return rand((@attack-@attack*ATTACK_AMPLITUDE_VARIATION)..(@attack+@attack*ATTACK_AMPLITUDE_VARIATION))
    end

    def load_animation()
        add_animation("down",[0,1,2,3]);
        add_animation("left",[4,5,6,7]);
        add_animation("right", [8,9,10,11]);
        add_animation("top", [12,13,14,15]);
    end

    def load_statistics()
        @hp_max = 100;
        @hp = @hp_max;

        @mp_max = 50;
        @mp = @mp_max;

        @energy_max = 80;
        @energy = @energy_max;
        @timer_wait_before_refill_energy = TIMER_WAIT_BEFORE_REFILL_ENERGY;

        @attack = 5;
    end

    def load_pickaxe()
        @pickaxe = Omega::Sprite.new("assets/pickaxe.png");
        @pickaxe.scale = Omega::Vector2.new(1,1)
        @pickaxe.origin = Omega::Vector2.new(-0.3,-0.3);

        @pickaxe_angle_destination = 0;
        @pickaxe_direction = -1;

        @hitbox_pickaxe = Omega::Rectangle.new(0,0,1,1);  
    end

    def load_hud_elements()
        @icon_heart = Omega::Sprite.new("assets/icon_heart.png")
        @icon_heart.origin = Omega::Vector2.new(0.5,0.5);
        @icon_heart.scale = Omega::Vector2.new(2,2);
        @icon_heart.position = Omega::Vector3.new(24, 24, 0);

        @icon_brick = Omega::Sprite.new("assets/icon_brick.png")
        @icon_brick.origin = Omega::Vector2.new(0.5,0.5);
        @icon_brick.scale = Omega::Vector2.new(2,2);
        @icon_brick.position = Omega::Vector3.new(24, 56, 0);

        @icon_pickaxe = Omega::Sprite.new("assets/icon_pickaxe.png");
        @icon_pickaxe.origin = Omega::Vector2.new(0.5,0.5);
        @icon_pickaxe.scale = Omega::Vector2.new(2,2);
        @icon_pickaxe.position = Omega::Vector3.new(24, 88, 0);
        @icon_pickaxe_alpha = 255;
        @timer_energy_blink = 0;

        @icon_bag = Omega::Sprite.new("assets/bag.png");
        @icon_bag.origin = Omega::Vector2.new(0.5,0.5);
        @icon_bag.scale = Omega::Vector2.new(2,2);
        @icon_bag.position = Omega::Vector3.new(42, Omega.height - 42, 0);
        @icon_bag.alpha = 255;
    end

    def update_velocity()
        if (@is_attacking) then
            @velocity.x = 0;
            @velocity.y = 0;
        end

        @position.x += @velocity.x
        @position.y += @velocity.y
    end

    def update_hitbox()
        @hitbox.position.x = @position.x-(@width*@scale.x*@origin.x) + 3
        @hitbox.position.y = @position.y-(@height*@scale.y*@origin.y) +15
        @hitbox.width = @width*@scale.x - 4;
        @hitbox.height = @height*@scale.y - 15;

        @can_draw_hitbox = !@can_draw_hitbox if Omega::just_pressed(Gosu::KB_P) #TODO To Remove
    end

    def update_damage()
        @color = (rand(0..50) == 0) ? Gosu::Color.new(80,120,120,120) : Gosu::Color.new(200,200,200,200);
        @timer_invicibility -= 0.1;

        if (@timer_invicibility < 0) then
            @color = Gosu::Color::WHITE;
            @can_take_damage = true;
        end
    end

    def update_inputs()
        return if (@is_attacking)

        # Movements 
        @velocity.x = @velocity.y = 0;
        if Omega::pressed(Gosu::KB_RIGHT) then
            @velocity.x = SPEED;
            play_animation("right") if @current_animation != "right" and @velocity.y == 0;
        elsif Omega::pressed(Gosu::KB_LEFT) then
            @velocity.x = -SPEED;
            play_animation("left") if @current_animation != "left" and @velocity.y == 0;
        elsif Omega::pressed(Gosu::KB_UP) then
            @velocity.y = -SPEED;
            play_animation("top") if @current_animation != "top";
        elsif Omega::pressed(Gosu::KB_DOWN) then
            @velocity.y = SPEED;
            play_animation("down") if @current_animation != "down";
        end

        # Pickaxe
        if (@energy >= ENERGY_COST && Omega::just_pressed(Gosu::KB_X)) then
            @is_attacking = true;
            $sounds["attack_pickaxe"].play();
            @energy -= ENERGY_COST;
            @timer_wait_before_refill_energy = TIMER_WAIT_BEFORE_REFILL_ENERGY;
            @energy = 0 if (@energy <= 0) 
            
            define_position_pickaxe();
        end

        # Bricks
        if (@mp >= MP_COST && Omega::just_pressed(Gosu::KB_C)) then
            @mp -= MP_COST;
            @mp = 0 if (@mp <= 0)
            @list_bricks.push(Brick.new(self));
        end

    end

    def update_pickaxe()
        @pickaxe.position.x = @position.x;
        @pickaxe.position.y = @position.y - 8;

        if (@pickaxe.angle != 0) then
            @pickaxe.angle += SPEED_PICKAXE * @pickaxe_direction;
        end

        if ((@pickaxe_direction == 1 && @pickaxe.angle >= @pickaxe_angle_destination) ||
            (@pickaxe_direction == -1 && @pickaxe.angle <= @pickaxe_angle_destination)) then
            @pickaxe.angle = 0 
            @is_attacking = false;
        end

        @hitbox_pickaxe.position.x = @pickaxe.position.x + Math.cos(Omega::to_rad(@pickaxe.angle)) * 36;
        @hitbox_pickaxe.position.y = @pickaxe.position.y + Math.sin(Omega::to_rad(@pickaxe.angle)) * 36;
        @hitbox_pickaxe.width = @pickaxe.width*@pickaxe.scale.x - 0;
        @hitbox_pickaxe.height = @pickaxe.height*@pickaxe.scale.y - 0;
    end

    def define_position_pickaxe()
        @pickaxe_direction = (@pickaxe_direction == 1) ? -1 : 1;

        if (@current_animation == "top")
            @pickaxe.angle = 160 + ((@pickaxe_direction == -1) ? PICKAXE_ANGLE_RANGE : 0);
        elsif (@current_animation == "right")
            @pickaxe.angle = 260 + ((@pickaxe_direction == -1) ? PICKAXE_ANGLE_RANGE : 0);
        elsif (@current_animation == "down")
            @pickaxe.angle = 340 + ((@pickaxe_direction == -1) ? PICKAXE_ANGLE_RANGE : 0);
        elsif (@current_animation == "left")
            @pickaxe.angle = 60 + ((@pickaxe_direction == -1) ? PICKAXE_ANGLE_RANGE : 0);
        end

        @pickaxe_angle_destination = @pickaxe.angle + ((@pickaxe_direction == 1) ? PICKAXE_ANGLE_RANGE : -PICKAXE_ANGLE_RANGE);
        # puts "current angle pickaxe: " + @pickaxe.angle.to_s + " to: " + @pickaxe_angle_destination.to_s;
    end

    def update_energy()
        if (@energy < ENERGY_COST) then
            @timer_energy_blink -= 0.01;

            if (@timer_energy_blink < 0) then
                @icon_pickaxe_alpha = (@icon_pickaxe_alpha >= 150) ? 40 : 160;
                @timer_energy_blink = HUD_ENERGY_BLINK_FREQUENCY;
            end
        end

        @timer_wait_before_refill_energy -= 0.01;

        if (@timer_wait_before_refill_energy < 0) then
            @energy += 1;
            @icon_pickaxe_alpha = 255;
            if (@energy >= @energy_max) then
                @energy = @energy_max;
            end
        end
    end

    def draw_hud()
        size_y = 12;

        # HP
        @icon_heart.draw();
        Gosu.draw_rect(@icon_heart.x + @icon_heart.width_scaled - HUD_THICKNESS, @icon_heart.y - HUD_THICKNESS - size_y*0.5, HUD_WIDTH_HP + (2*HUD_THICKNESS), size_y + (2*HUD_THICKNESS), Gosu::Color.new(255,255,255,255))
        Gosu.draw_rect(@icon_heart.x + @icon_heart.width_scaled, @icon_heart.y - size_y*0.5,(@hp * HUD_WIDTH_HP)/@hp_max,size_y,Gosu::Color.new(255, 10, 200, 8));

        # MP
        @icon_brick.draw();

        alpha_mp = (@mp < MP_COST) ? 60 : 255

        Gosu.draw_rect(@icon_brick.x + @icon_brick.width_scaled - HUD_THICKNESS, @icon_brick.y-HUD_THICKNESS - size_y*0.5, HUD_WIDTH_MP + (2*HUD_THICKNESS), size_y + (2*HUD_THICKNESS), Gosu::Color.new(alpha_mp,255,255,255))
        Gosu.draw_rect(@icon_brick.x + @icon_brick.width_scaled, @icon_brick.y - size_y*0.5,(@mp * HUD_WIDTH_MP)/@mp_max,size_y,Gosu::Color.new(alpha_mp, 10, 8, 200));

        # Energy
        @icon_pickaxe.draw();
        Gosu.draw_rect(@icon_pickaxe.x + @icon_pickaxe.width_scaled - HUD_THICKNESS, @icon_pickaxe.y - size_y*0.5 - HUD_THICKNESS, HUD_WIDTH_ENERGY + (2*HUD_THICKNESS), size_y + (2*HUD_THICKNESS), Gosu::Color.new(@icon_pickaxe_alpha,255,255,255));
        Gosu.draw_rect(@icon_pickaxe.x + @icon_pickaxe.width_scaled, @icon_pickaxe.y - size_y*0.5,(@energy * HUD_WIDTH_ENERGY)/@energy_max,size_y, Gosu::Color.new(@icon_pickaxe_alpha, 255, 127, 39));

        # Bag
        @icon_bag.draw();

        if (@icon_bag.scale.x >= DEFAULT_BAG_SCALE) then
            @icon_bag.scale.x = @icon_bag.scale.y -= 0.4;

            if (@icon_bag.scale.x <= DEFAULT_BAG_SCALE) then
                @icon_bag.scale.x = @icon_bag.scale.y = DEFAULT_BAG_SCALE;
            end
        end

        for i in 0...@list_loot_info.length do
            next if @list_loot_info[i] == nil

            @list_loot_info[i].draw() 
            
            if (@list_loot_info[i].alpha <= 0) then
                @list_loot_info.delete_at(i);
            end
        end
    end

end