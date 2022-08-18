class LootInfo

    SPEED = 7;
    SPEED_ALPHA = 6;
    THICKNESS = 4;
    TRAVEL_DISTANCE = 120;

    attr_reader :alpha

    def initialize(resource, pos)
        @alpha = 255;
        @current_speed = SPEED;
        @resource = resource;
        load(resource, pos)
    end

    def load(resource, pos)
        @icon = Omega::SpriteSheet.new("assets/loot.png",16,24);
        @icon.position = pos.clone;
        @icon.scale = Omega::Vector2.new(2,2);
        @initial_position = pos.clone;
        @text = Omega::Text.new("+1", $font);
        @text.position = Omega::Vector3.new(@icon.position.x + @icon.width_scaled + 4, @icon.position.y + @icon.height*0.5,0);
        @text.scale = Omega::Vector2.new(0.5,0.5);
        load_animation();
        @icon.play_animation("IDLE");
    end

    def draw
        @icon.y -= @current_speed;
        @text.y -= @current_speed;
1
        if (@icon.y <= @initial_position.y - TRAVEL_DISTANCE) then
            @current_speed = 0;
        end

        if (@current_speed <= 0) then
            @alpha -= SPEED_ALPHA;
        end

        @alpha = 0 if (@alpha <= 0)

        @icon.color = Gosu::Color.new(@alpha,255,255,255);
        @text.color = Gosu::Color.new(@alpha,255,255,255);


        Gosu.draw_rect(@icon.x - THICKNESS, @icon.y - THICKNESS, 
                        @icon.width_scaled + @text.width + 2*THICKNESS, 56, 
                        Gosu::Color.new(((@alpha <= 10) ? @alpha : 10),0,0,0))

        @icon.draw();
        @text.draw();
    end

    def load_animation
        case @resource
        when "Grass"  
            @icon.add_animation("IDLE", [0])
        when "Stone"  
            @icon.add_animation("IDLE", [1])
        when "Sand"
            @icon.add_animation("IDLE", [2])
        when "Water" 
            @icon.add_animation("IDLE", [3])
        when "Wood"  
            @icon.add_animation("IDLE", [4])
        when "Glass"
            @icon.add_animation("IDLE", [5])
        when "Mana" 
            @icon.add_animation("IDLE", [6])
        end
    end
end