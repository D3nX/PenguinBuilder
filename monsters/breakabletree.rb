class BreakableTree < Monster

    def initialize(hero, camera, map)
        super(hero, camera, map,"assets/tree.png", 38, 62, 50, 0)
        set_loot(9,["Wood"], 90)

        # Every monsters have to possess a HIT and DIE animation
        add_animation("IDLE", [0]);
        add_animation("HIT", [0])
        add_animation("DIE", [0]);
        play_animation("IDLE");

        @hitbox_offset = Omega::Rectangle.new(5,8,-10,-14);
    end

    def update()
        super()
    end

    def draw()
        super()
    end

end