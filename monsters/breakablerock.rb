class BreakableRock < Monster

    def initialize(hero, camera)
        super(hero, camera, "assets/rock.png", 40, 40, 54, 0)
        set_loot(6,["Stone"], 90)

        # Every monsters have to possess a HIT and DIE animation
        add_animation("IDLE", [0]);
        add_animation("HIT", [0])
        add_animation("DIE", [0]);
        play_animation("IDLE");

        @hitbox_offset = Omega::Rectangle.new(5,12,-10,-24);
    end

    def update()
        super()
    end

    def draw()
        super()
    end

end