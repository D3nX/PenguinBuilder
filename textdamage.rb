class TextDamage < Omega::Text

    FORCE_JUMP = 5;
    GRAVITY = 0.6;
    DISPARITION_SPEED = 8;

    def initialize(damage, position, scale)
        super(damage.to_i.to_s, $font);

        @initial_position = Omega::Vector3.new(position.x, position.y + 5, 0);
        @position = @initial_position.clone;
        @velocity = Omega::Vector2.new(0,-FORCE_JUMP);
        @scale = Omega::Vector2.new(scale,scale);
        @alpha = 255;
    
        @has_reach_max_y = false;
        @can_remove = false;
    end

    def update()
        update_velocity();

        if (!@has_reach_max_y) then
            update_gravity()
            return
        end

        disparition();
    end

    def draw()
        @color = Gosu::Color.new(@alpha, @color.red, @color.blue, @color.green);
        super();
    end

    def update_velocity()
        @position.x += @velocity.x;
        @position.y += @velocity.y;
    end

    def update_gravity()
        @velocity.y += GRAVITY;

        if (@position.y >= @initial_position.y) then
            @position.y = @initial_position.y
            @velocity.y = 0;
            @has_reach_max_y = true;
        end
    end

    def disparition()
        @alpha -= DISPARITION_SPEED;

        if (@alpha <= 0) then
            @alpha = 0;
            @can_remove = true;
        end
    end

end