class Brick < Omega::Sprite

    SPEED = 6;
    ANGLE_SPEED = 24;

    attr_reader :hitbox

    def initialize(hero)
        super("assets/brick.png")

        @hero = hero;
        @position = @hero.position.clone;
        @velocity = Omega::Vector2.new(0,0);
        @origin = Omega::Vector2.new(0.5,0.5);

        $sounds["throw_brick"].play();
        @hitbox = Omega::Rectangle.new(0,0,1,1);

        define_velocity();
    end

    def update()
        update_velocity();
        update_hitbox();

        @angle += ANGLE_SPEED;
    end

    def draw()
        super();
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

    def define_velocity()
        if (@hero.current_animation == "left") then
            @velocity.x = -SPEED;
        elsif (@hero.current_animation == "right") then
            @velocity.x = SPEED;
        elsif (@hero.current_animation == "top") then
            @velocity.y = -SPEED;
        elsif (@hero.current_animation == "down") then
            @velocity.y = SPEED;
        end
    end

end