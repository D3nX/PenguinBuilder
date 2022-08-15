class Hero < Omega::SpriteSheet

    SPEED = 2;
    SPEED_PICKAXE = 15;
    PICKAXE_ANGLE_RANGE = 150;
    ATTACK_AMPLITUDE_VARIATION = 0.1
    TIMER_INVINCIBILTY = 2.5

    attr_reader :hitbox, :hitbox_pickaxe, :velocity, :attack, :hp, :hp_max, :mp, :mp_max, :is_attacking, :bag_resources
    attr_accessor :bag_resources;

    def initialize(cam)
        super("assets/hero.png",16,24);
        @origin = Omega::Vector2.new(0.5,0.5);

        load_statistics();
        load_resources();

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
    end

    def update()
        update_velocity();
        update_hitbox();
        update_inputs();
        update_damage() if (!@can_take_damage)
        update_pickaxe() if (@is_attacking)
        
    end

    def draw()
        super();

        @pickaxe.draw() if @is_attacking

        # DEBUG
        @hitbox.draw if (@can_draw_hitbox)
        @hitbox_pickaxe.draw if (@can_draw_hitbox)
    end

    def load_resources()
        @bag_resources = {
            Resource::DIRT  => 0,
            Resource::SAND  => 0,
            Resource::WATER => 0,
            Resource::ROCK  => 0,
            Resource::WOOD  => 0
        }
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
        value = rand((@attack-@attack*ATTACK_AMPLITUDE_VARIATION)..(@attack+@attack*ATTACK_AMPLITUDE_VARIATION))
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

    def update_velocity()
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

        # pickaxe
        if (Omega::just_pressed(Gosu::KB_X)) then
            @is_attacking = true;
            define_position_pickaxe();
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
        # puts "current pickaxe: " + @pickaxe.angle.to_s + " to: " + @pickaxe_angle_destination.to_s;
    end

end