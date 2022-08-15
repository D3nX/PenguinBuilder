class Loot < Omega::Sprite

    def initialize(resource)
        super("none");
        @resource = resource;

    end

    def update()
        update_velocity();

    end

    def draw()
        super();
        
    end

    def update_velocity()
        @position.x += @velocity.x;
        @position.y += @velocity.y;
    end

end