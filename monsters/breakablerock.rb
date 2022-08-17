class BreakableRock < Monster

    def initialize(hero, camera)
        super(hero, camera, "assets/breakable_rock.png", 32, 32, 50, 0)
        set_loot(15,[Resource::ROCK], 90)

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