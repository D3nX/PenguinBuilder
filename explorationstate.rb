class ExplorationState < Omega::State

    def load
        @camera = Omega::Camera.new(false)
        @camera.scale = Omega::Vector2.new(3,3)
        
        @hero = Hero.new(@camera);
        @hero.position = Omega::Vector3.new(22 * 16, 16 * 16, 0);
        @camera.follow(@hero, 0.4)

        @rockdood = Rockdood.new(@hero, @camera);
        @rockdood.position = Omega::Vector3.new(22*16,5*16,0);

        @breakable_rock = BreakableRock.new(@hero, @camera)
        @breakable_rock.position = Omega::Vector3.new(18*16,12*16,0);

        @breakable_tree = BreakableTree.new(@hero, @camera)
        @breakable_tree.position = Omega::Vector3.new(10*16,11*16,0);

        @breakable_cactus = BreakableCactus.new(@hero, @camera)
        @breakable_cactus.position = Omega::Vector3.new(12*16,13*16,0);

        @breakable_bush = BreakableBush.new(@hero, @camera)
        @breakable_bush.position = Omega::Vector3.new(7*16,13*16,0);

        @smokey = Smokey.new(@hero, @camera);
        @smokey.position = Omega::Vector3.new(12*16,10*16,0);

        @map = IsoMap.new("assets/ctileset.png",48,20);
        @map.load_csv_layer("assets/maps/map_plains_layer_0.csv");
        @map.load_csv_layer("assets/maps/map_plains_layer_1.csv");
        @map.load_csv_layer("assets/maps/map_plains_layer_2.csv");
        @map.light = nil
    end

    def update()
       @hero.update();

       Omega.set_state(GameOverState.new) if (@hero.hp <= 0)
       Omega.set_state(BackToVillageState.new) if (@hero.position.x >= @map.width * IsoMap::TILE_WIDTH || @hero.position.x <= 0 || @hero.position.y >= @map.height * IsoMap::TILE_WIDTH || @hero.position.y <= 0)

       @rockdood.update();
       @smokey.update();

       @breakable_rock.update();
       @breakable_tree.update();
       @breakable_cactus.update();
       @breakable_bush.update();

       update_collision_with_map();
    end

    def draw()
        @camera.draw() do
            @map.draw();

            @hero.draw();

            @rockdood.draw();
            @smokey.draw();

            @breakable_rock.draw();
            @breakable_tree.draw();
            @breakable_cactus.draw();
            @breakable_bush.draw();
        end

        @hero.draw_hud();
    end

    def update_collision_with_map()
        solid_tiles = [3]; # add here other solid tiles that need collision on **LAYER 0**
        tile_size = IsoMap::TILE_WIDTH;

        for z in 0..1 do
            # Collision top
            tile1 = @map.tile_at((@hero.hitbox.x+2)/tile_size, (@hero.hitbox.y-2)/tile_size, z)
            tile2 = @map.tile_at((@hero.hitbox.x+@hero.hitbox.width-2)/tile_size, (@hero.hitbox.y-2)/tile_size, z)

            if @hero.velocity.y < 0 && check_collision(tile1, tile2, z, solid_tiles) then 
                @hero.velocity.y = 0; 
            end 

            # Collision right
            tile1 = @map.tile_at((@hero.hitbox.x + @hero.hitbox.width + 2)/tile_size, (@hero.hitbox.y + 2)/tile_size, z)
            tile2 = @map.tile_at((@hero.hitbox.x + @hero.hitbox.width + 2)/tile_size, (@hero.hitbox.y + @hero.hitbox.height - 2)/tile_size, z)

            if @hero.velocity.x > 0 && check_collision(tile1, tile2, z, solid_tiles) then 
                @hero.velocity.x = 0; 
            end 

            # Collision left
            tile1 = @map.tile_at((@hero.hitbox.x - 2)/tile_size, (@hero.hitbox.y + 2)/tile_size, z)
            tile2 = @map.tile_at((@hero.hitbox.x - 2)/tile_size, (@hero.hitbox.y + @hero.hitbox.height - 2)/tile_size, z)

            if @hero.velocity.x < 0 && check_collision(tile1, tile2, z, solid_tiles) then 
                @hero.velocity.x = 0; 
            end 

            # Collision bottom
            tile1 = @map.tile_at((@hero.hitbox.x + 2)/tile_size, (@hero.hitbox.y + @hero.hitbox.height + 2)/tile_size, z)
            tile2 = @map.tile_at((@hero.hitbox.x+@hero.hitbox.width-2)/tile_size, (@hero.hitbox.y + @hero.hitbox.height + 2)/tile_size, z)

            if @hero.velocity.y > 0 && check_collision(tile1, tile2, z, solid_tiles) then 
                @hero.velocity.y = 0; 
            end 
            
        end
    end

    def check_if_tile_is_solid(list_solid_tiles, tile_to_check)
        for i in 0...list_solid_tiles.length do
            if (tile_to_check == list_solid_tiles[i]) then
                return true;
            end
        end
        return false;
    end

    def check_collision(tile1, tile2, z, solid_tiles)
        return (tile1 != nil && check_if_tile_is_solid(solid_tiles, tile1.id)) || (tile2 != nil && check_if_tile_is_solid(solid_tiles, tile2.id)) || ((z != 0 && tile1 != nil) || (z != 0 && tile2 != nil))
    end

end