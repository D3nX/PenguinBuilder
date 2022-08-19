class GameOverState < Omega::State

    PERCENTAGE_TO_LOOSE = 75
    TIMER_LOOSE_RESOURCE = 0.012

    def load
        @hero = Omega::SpriteSheet.new("hero.png", 16, 24);
        @hero.add_animation("DIE", [0]);
        @hero.play_animation("DIE");
        @hero.scale.x = @hero.scale.y = 2;
        @hero.origin.x = @hero.origin.y = 0.5;

        @list_loot_icon = [];

        @timer_loose_resource = TIMER_LOOSE_RESOURCE;
        @nb_resource_to_loose = (($hero_inventory["Grass"]*PERCENTAGE_TO_LOOSE)/100).to_i;
    end

    def update
        @timer_loose_resource -= 0.01

        if (@timer_loose_resource < 0) then
            if (@nb_resource_to_loose > 0) then
                decrease_inventory_randomly();
                @nb_resource_to_loose -= 1; 
            end
            @timer_loose_resource = TIMER_LOOSE_RESOURCE;
        end

        for i in 0...list_loot_icon.length do
            list_loot_icon[i].update();
        end

    end

    def draw
        for i in 0...list_loot_icon.length do
            list_loot_icon[i].draw();
        end
    end

    def decrease_inventory_randomly(quantity)

    end

end