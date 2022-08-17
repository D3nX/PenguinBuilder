class Loot < Omega::SpriteSheet

    TIMER_BEFORE_BEING_COLLECTABLE = 0.16
    MIN_SCALE = 0.4
    MAX_SCALE = 1.2


    attr_reader :is_collected
    attr_accessor :velocity

    def initialize(hero, resource)
        super("assets/loot.png",16,24);
        @resource = resource;
        load_animation();
        play_animation("IDLE");

        @origin = Omega::Vector2.new(0.5,0.5);
        @hero = hero;

        @hitbox = Omega::Rectangle.new(0,0,1,1);
        @velocity = Omega::Vector2.new(0,0);
        @time = 0.0;

        @is_collected = false;

        @timer_before_being_collectable = TIMER_BEFORE_BEING_COLLECTABLE;
    end

    def load_animation()
        case @resource
        when Resource::DIRT  
            add_animation("IDLE", [0])
        when Resource::SAND  
            add_animation("IDLE", [2])
        when Resource::WATER 
            add_animation("IDLE", [3])
        when Resource::ROCK  
            add_animation("IDLE", [1])
        when Resource::WOOD  
            add_animation("IDLE", [4])
        when Resource::MANA 
             add_animation("IDLE", [6])
        end
    end

    def update()
        update_velocity();
        update_scale();
        update_hitbox();

        @timer_before_being_collectable -= 0.01

        if (@timer_before_being_collectable < 0) then
            @velocity.x = @velocity.y = 0;
            @timer_before_being_collectable = -1;
        end

        if (!@is_collected && @timer_before_being_collectable < 0 && @hitbox.collides?(@hero.hitbox)) then
            @hero.collect_resource(@resource)
            $sounds["item_collected"].play();
            @is_collected = true;
        end
    end

    def draw()
        super() if (!@is_collected)
        
    end

    def update_velocity()
        @position.x += @velocity.x;
        @position.y += @velocity.y;
    end

    def update_hitbox()
        @hitbox.position.x = @position.x-(@width*@scale.x*@origin.x) + 0
        @hitbox.position.y = @position.y-(@height*@scale.y*@origin.y) +0
        @hitbox.width = @width*@scale.x - 0;
        @hitbox.height = @height*@scale.y - 0;
    end

    def update_scale()
        @time += 0.1;

        value =  Math.cos(@time) * 0.5;
        @scale = Omega::Vector2.new(0.5 + value, 0.5 + value);

        @scale.x = @scale.y = MIN_SCALE if (@scale.x <= MIN_SCALE) 
        @scale.x = @scale.y = MAX_SCALE if (@scale.x >= MAX_SCALE)
    end

end