class Volcanicdood < Monster

    SPEED = 0.22
    DISTANCE_DETECTION = 100
    MUSIC_DISTANCE_DETECTION = 160
    HUD_THICKNESS = 4;

    def initialize(hero, camera)
        super(hero, camera, "assets/volcanicdood.png", 30, 40, 660, 17)
        set_loot(30,["Glass", "Stone", "Mana"], 75)

        @name = "Volcanic Dood";

        @base_scale = Omega::Vector2.new(2.5,2.5);
        @scale = @base_scale.clone;

        # Every monsters have to possess a HIT and DIE animation
        add_animation("IDLE", [0]);

        add_animation("DOWN", [0,1,2,3]);
        add_animation("TOP", [4,5,6,7]);
        add_animation("RIGHT", [8,9,10,11]);
        add_animation("LEFT", [12,13,14,15]);
        add_animation("HIT", [16]);

        add_animation("DIE", [16]);

        @hitbox_offset = Omega::Rectangle.new(8,28,-16,-40);
        
    end

    def update()
        if (@hp < 0) then @velocity.x = @velocity.y = 0; end
        update_music_detection();

        super()

        # Update only if rockdood is near the hero
        if (!@can_take_damage || Omega.distance(@hero.position, @position) > DISTANCE_DETECTION) then
            @velocity.x = @velocity.y = 0;
            return
        end

        if (@hero.position.y <= @position.y - 8) then
            play_animation("TOP") if (@current_animation != "TOP")
            @velocity.y = -SPEED;
        end

        if (@hero.position.y >= @position.y + 8) then
            play_animation("DOWN") if (@current_animation != "DOWN")
            @velocity.y = SPEED;
        end

        if (@hero.position.x <= @position.x - 8) then
            play_animation("LEFT") if (@current_animation != "LEFT" && @velocity.y == 0)
            @velocity.x = -SPEED;
        end

        if (@hero.position.x >= @position.x + 8) then
            play_animation("RIGHT") if (@current_animation != "RIGHT" && @velocity.y == 0)
            @velocity.x = SPEED;
        end

        
    end

    def draw()
        super()
    end

    def update_music_detection()
        @can_draw_hud = @boss_music_is_launch;

        if (!@boss_music_is_launch && Omega.distance(@hero.position, @position) <= MUSIC_DISTANCE_DETECTION) then

            $musics[$current_map].volume -= 0.02;

            if ($musics[$current_map].volume <= 0) then
                $musics["boss"].play(true);
                $musics["boss"].volume = 1.0
                @boss_music_is_launch = true;
            end
        end

        if (@hp <= 0 || (@boss_music_is_launch && Omega.distance(@hero.position, @position) > MUSIC_DISTANCE_DETECTION)) then
            $musics["boss"].volume -= 0.02;

            if ($musics["boss"].volume <= 0) then
                $musics[$current_map].play(true);
                $musics[$current_map].volume = 1.0
                @boss_music_is_launch = false;
            end
        end

        if (@hp > 0 && @boss_music_is_launch && Omega.distance(@hero.position, @position) <= MUSIC_DISTANCE_DETECTION && $musics["boss"].volume < 1.0) then
            $musics["boss"].volume += 0.2
            $musics["boss"].volume = 1.0 if ($musics["boss"].volume >= 1.0)
        end
    end

end