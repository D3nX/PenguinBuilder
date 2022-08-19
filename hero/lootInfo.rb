class LootInfo < LootIcon

    SPEED = 7;
    SPEED_ALPHA = 6;
    THICKNESS = 4;
    TRAVEL_DISTANCE = 120;

    attr_reader :alpha

    def initialize(resource, pos)
        super(resource.to_s);
        @alpha = 255;
        @current_speed = SPEED;
        load_elements(pos)
    end

    def load_elements(pos)
        @position = pos.clone;
        @scale = Omega::Vector2.new(2, 2);
        @initial_position = pos.clone;

        @text = Omega::Text.new("+1", $font);
        @text.position = Omega::Vector3.new(@position.x + @width + 4, @position.y + @height*0.5, 0);
        @text.scale = Omega::Vector2.new(0.5,0.5);
    end

    def update()
        super();
    end

    def draw
        super()
        @position.y -= @current_speed;
        @text.y -= @current_speed;
1
        if (@position.y <= @initial_position.y - TRAVEL_DISTANCE) then
            @current_speed = 0;
        end

        if (@current_speed <= 0) then
            @alpha -= SPEED_ALPHA;
        end

        @alpha = 0 if (@alpha <= 0)

        @color = Gosu::Color.new(@alpha,255,255,255);
        @text.color = Gosu::Color.new(@alpha,255,255,255);

        Gosu.draw_rect(@position.x - THICKNESS, @position.y - THICKNESS, 
                        @width + @text.width + 2*THICKNESS, 56, 
                        Gosu::Color.new(((@alpha <= 10) ? @alpha : 10),0,0,0))

        @text.draw();
    end

end