class LootIcon < Omega::SpriteSheet

    attr_reader :resource;
    attr_accessor :velocity;


    def initialize(resource) 
        super("assets/loot.png",16,24);
        load_animation(resource);
        play_animation("IDLE");

        @resource = resource;
        @velocity = Omega::Vector2.new(0,0);

    end

    def update
        update_velocity();
    end

    def draw()
        super
    end

    def load_animation(resource)
        case resource
        when "Grass"  
            add_animation("IDLE", [0])
        when "Stone"  
            add_animation("IDLE", [1])
        when "Sand"
            add_animation("IDLE", [2])
        when "Water" 
            add_animation("IDLE", [3])
        when "Wood"  
            add_animation("IDLE", [4])
        when "Glass"
            add_animation("IDLE", [5])
        when "Mana" 
            add_animation("IDLE", [6])
        end
    end

    def update_velocity
        @position.x += @velocity.x;
        @position.y += @velocity.y;
    end

end