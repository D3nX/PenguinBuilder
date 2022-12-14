class BreakableBush < Monster

    def initialize(hero, camera, map)
        super(hero, camera, map, "assets/bush.png", 28, 14, 32, 0)
        set_loot(13,["Dirt", "Bush"], 90)

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