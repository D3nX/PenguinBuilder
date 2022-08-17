class Rockdood < Monster


    def initialize(hero, camera)
        super(hero, camera, "assets/rockdood.png", 78, 78, 61, 5)
        set_loot(12,[Resource::DIRT, Resource::ROCK, Resource::MANA], 75)

        # Every monsters have to possess a HIT and DIE animation
        add_animation("IDLE", [0,1,2,3]);
        add_animation("HIT", [4])
        add_animation("DIE", [4]);
        play_animation("IDLE");
    end

    def update()
        super()
    end

    def draw()
        super()
    end


end