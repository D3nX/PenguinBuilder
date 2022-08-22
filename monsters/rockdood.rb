class Rockdood < Monster

    SPEED = 0.4
    DISTANCE_DETECTION = 130

    def initialize(hero, camera)
        super(hero, camera, "assets/rockdood.png", 30, 40, 78, 12)
        set_loot(5,["Grass", "Stone", "Mana"], 75)

        # Every monsters have to possess a HIT and DIE animation
        add_animation("IDLE", [0]);

        add_animation("DOWN", [0,1,2,3]);
        add_animation("TOP", [4,5,6,7]);
        add_animation("RIGHT", [8,9,10,11]);
        add_animation("LEFT", [12,13,14,15]);
        add_animation("HIT", [16]);

        add_animation("DIE", [16]);
    end

    def update()
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
        
        #puts "velocity x : " + @velocity.x.to_s + " | " + @velocity.y.to_s
    end

    def draw()
        super()
    end


end