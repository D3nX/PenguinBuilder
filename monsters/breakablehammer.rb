class BreakableHammer < Monster

    DISTANCE_DETECTION = 140

    def initialize(hero, camera)
        super(hero, camera, "assets/chaos_penguin_hammer.png", 32, 56, 1, 1)
        set_loot(1,["???"], 0)

        @name = "???"

        # Every monsters have to possess a HIT and DIE animation
        add_animation("IDLE", [0]);
        add_animation("HIT", [0])
        add_animation("DIE", [0]);
        play_animation("IDLE");

        @angle = 38;

        @is_invincible = true;
        @boss_music_is_launch = false;
    end

    def update()
        super()

        update_music_detection();
    end

    def draw()
        super()
    end

    def update_music_detection()
        @can_draw_hud = @boss_music_is_launch;

        if (!@boss_music_is_launch && Omega.distance(@hero.position, @position) <= DISTANCE_DETECTION) then

            $musics[$current_map].volume -= 0.02;

            if ($musics[$current_map].volume <= 0) then
                $musics["chaos_penguin"].play(true);
                $musics["chaos_penguin"].volume = 1.0
                @boss_music_is_launch = true;
            end
        end

        if (@hp <= 0 || (@boss_music_is_launch && Omega.distance(@hero.position, @position) > DISTANCE_DETECTION)) then
            $musics["chaos_penguin"].volume -= 0.02;

            if ($musics["chaos_penguin"].volume <= 0) then
                $musics[$current_map].play(true);
                $musics[$current_map].volume = 1.0
                @boss_music_is_launch = false;
            end
        end
    end

end