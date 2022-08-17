class ExplorationState < Omega::State

    def load
        @camera = Omega::Camera.new(false)
        @camera.scale = Omega::Vector2.new(3, 3)
        
        @hero = Hero.new(@camera);
        @camera.follow(@hero, 0.4)

        @rockdood = Rockdood.new(@hero, @camera);
        @rockdood.position = Omega::Vector3.new(0,-100,0);

        @loot = Loot.new(@hero, Resource::SAND);

        @map = IsoMap.new("assets/ctileset.png",48*16,20*16);
        @map.load_csv_layer("assets/maps/map_plains_layer_0.csv");
        @map.load_csv_layer("assets/maps/map_plains_layer_1.csv");
        @map.load_csv_layer("assets/maps/map_plains_layer_2.csv");
        @map.light = nil
    end

    def update
       @hero.update();

       @rockdood.update();

       @loot.update();
    end

    def draw
        @camera.draw do
            @map.draw();

            @hero.draw();

            @rockdood.draw();

            @loot.draw();
        end

        @hero.draw_hud();
    end

end