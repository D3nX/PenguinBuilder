class Loot < LootIcon

    SPEED = 4;

    MIN_SCALE = 0.6
    MAX_SCALE = 1.5

    TIMER_BEFORE_BEING_COLLECTABLE = 0.12
    TIMER_BEFORE_GOING_TOWARD_HERO = 0.8;

    attr_reader :is_collected
    attr_accessor :velocity

    def initialize(hero, resource)
        super(resource)
        @resource = resource;

        @origin = Omega::Vector2.new(0.5,0.5);
        @hero = hero;

        @hitbox = Omega::Rectangle.new(0,0,1,1);
        @velocity = Omega::Vector2.new(0,0);
        @time = 0.0;

        @is_collected = false;

        @timer_before_being_collectable = TIMER_BEFORE_BEING_COLLECTABLE;
        @timer_before_going_toward_hero = TIMER_BEFORE_GOING_TOWARD_HERO;
    end

    def update()
        return if (@is_collected)

        super();
        update_scale();
        update_hitbox();

        @timer_before_being_collectable -= 0.01

        if (@timer_before_being_collectable < 0) then
            if (@timer_before_going_toward_hero > 0) then
                @velocity.x = @velocity.y = 0 
            end
            @timer_before_being_collectable = -1;
        end

        if (!@is_collected && @timer_before_being_collectable < 0 && @hitbox.collides?(@hero.hitbox)) then
            @hero.collect_resource(@resource)
            $sounds["item_collected"].play();
            @is_collected = true;
        end

        @timer_before_going_toward_hero -= 0.01

        if (@timer_before_going_toward_hero < 0) then
            @timer_before_going_toward_hero = -1;

            @velocity.x = -SPEED if (@hero.hitbox.x + @hero.hitbox.width*0.5 < @position.x)
            @velocity.x = SPEED if (@hero.hitbox.x + @hero.hitbox.width*0.5 > @position.x)
            @velocity.y = -SPEED if (@hero.hitbox.y + @hero.hitbox.height*0.5 < @position.y)
            @velocity.y = SPEED if (@hero.hitbox.y + @hero.hitbox.height*0.5 > @position.y)
        end
    end

    def draw()
        super() if (!@is_collected)
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