class BreakableCactus < Monster

    def initialize(hero, camera)
        super(hero, camera, "assets/cactus.png", 24, 48, 40, 5)
        set_loot(11,["Water", "Sand", "Cactus"], 90)

        # Every monsters have to possess a HIT and DIE animation
        add_animation("IDLE", [0]);
        add_animation("HIT", [0])
        add_animation("DIE", [0]);
        play_animation("IDLE");
    end

    def update()
        super()
    end

    def draw()
        super()
    end

end