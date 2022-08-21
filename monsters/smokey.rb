class Smokey < Monster

    TIMER_DIRECTION = 0.2;
    TIMER_WAIT = 0.5;
    SPEED = 0.8;

    def initialize(hero, camera)
        super(hero, camera, "assets/smokey.png", 30, 30, 51, 9)
        set_loot(6,["Water", "Dirt", "Mana"], 75)

        # Every monsters have to possess a HIT and DIE animation
        add_animation("IDLE", [0]);

        add_animation("DOWN", [0,1,2,1]);
        add_animation("TOP", [3,4,5,4]);
        add_animation("HIT", [6]);
        add_animation("DIE", [6]);

        @velocity.y = SPEED;
        play_animation("DOWN")

        @timer_direction = TIMER_DIRECTION;
        @timer_wait = TIMER_WAIT;
    end

    def update()
        super()

        @timer_direction -= 0.01

         if (!@can_take_damage || @hp <= 0) then
            @velocity.x = @velocity.y = 0;
            return
        end

        if (@timer_direction < 0) then
            @velocity.x = @velocity.y = 0;

            @timer_wait -= 0.01;

            if (@timer_wait < 0) then
                choose_random_direction();
                @timer_direction = TIMER_DIRECTION;
                @timer_wait = TIMER_WAIT;
            end
        end

    end

    def draw()
        super()
    end

    def choose_random_direction()
        horizontal_or_vertical = rand(0..1)

        if (horizontal_or_vertical == 0) then
            # Horizontal
            @velocity.x = (rand(0..1) == 0) ? SPEED : -SPEED;
        else
            # Vertical
            @velocity.y = (rand(0..1) == 0) ? SPEED : -SPEED;

            play_animation("TOP") if (@current_animation != "TOP" && @velocity.y < 0)
            play_animation("DOWN") if (@current_animation != "DOWN" && @velocity.y > 0)

            
        end
    end

end