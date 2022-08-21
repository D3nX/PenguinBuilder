class ExplorationState < Omega::State

    def load
        @camera = Omega::Camera.new(false)
        @camera.scale = Omega::Vector2.new(3,3)
        
        @hero = Hero.new(@camera);
        @hero.position = Omega::Vector3.new(0,0,0);
        @camera.follow(@hero, 0.4)

        @text = Omega::Text.new("", $font)

        $musics[$current_map].play(true)

        @map = IsoMap.new("assets/ctileset.png",48,20);
        @map.load_csv_layer("assets/maps/" + $current_map + "_layer_0.csv");
        @map.load_csv_layer("assets/maps/" + $current_map +"_layer_1.csv");
        @map.load_csv_layer("assets/maps/" + $current_map +"_layer_2.csv");
        @map.light = nil;

        @list_monsters = [];

        load_entities()

        @substate = nil
    end

    def update()
        if @substate
            @substate.update
            @substate = nil if @substate.finished
            return
        end

        if Omega::just_pressed(Gosu::KB_ESCAPE)
            @substate = QuestState.new
            @substate.load(true, true)
            return
        end

       @hero.update();

       for i in 0...@list_monsters.length do
            @list_monsters[i].update();
       end

       Omega.set_state(GameOverState.new) if (@hero.hp <= 0)
       Omega.set_state(BackToVillageState.new) if (@hero.position.x >= @map.width * IsoMap::TILE_WIDTH || @hero.position.x <= 0 || @hero.position.y >= @map.height * IsoMap::TILE_WIDTH || @hero.position.y <= 0)

       update_collision_with_map();
    end

    def draw()
        if @substate
            @substate.draw
            return
        end

        @camera.draw() do
            @map.draw();

            @hero.draw();

            for i in 0...@list_monsters.length do
                @list_monsters[i].draw();
           end
        end

        # Interfaces :
        @hero.draw_hud();
        draw_controls()
    end


    def load_entities()
        map_entities = Omega::Map.new("assets/edit_tileset.png", 16)
        map_entities.load_layer("entities", "assets/maps/" + $current_map.to_s + "_entities.csv")
        map_entities.set_type(10, "hero")
        map_entities.set_type(11, "rockdood")
        map_entities.set_type(12, "smokey")
        map_entities.set_type(13, "bush")
        map_entities.set_type(14, "cactus")
        map_entities.set_type(15, "tree")
        map_entities.set_type(16, "rock")

        map_entities.layers["entities"].each do |t|
            if t.type == "hero"
                @hero.position = Omega::Vector3.new(t.position.x, t.position.y, 0);
                @camera.follow(@hero, 0.4)
            elsif t.type == "rockdood"
                rockdood = Rockdood.new(@hero, @camera)
                rockdood.position = Omega::Vector3.new(t.position.x, t.position.y, 0);
                @list_monsters.push(rockdood)
            elsif t.type == "smokey"
                smokey = Smokey.new(@hero, @camera)
                smokey.position = Omega::Vector3.new(t.position.x, t.position.y, 0);
                @list_monsters.push(smokey)
            elsif t.type == "bush"
                bush = BreakableBush.new(@hero, @camera)
                bush.position = Omega::Vector3.new(t.position.x, t.position.y, 0);
                @list_monsters.push(bush)
            elsif t.type == "cactus"
                cactus = BreakableCactus.new(@hero, @camera)
                cactus.position = Omega::Vector3.new(t.position.x, t.position.y, 0);
                @list_monsters.push(cactus)
            elsif t.type == "tree"
                tree = BreakableTree.new(@hero, @camera)
                tree.position = Omega::Vector3.new(t.position.x, t.position.y, 0);
                @list_monsters.push(tree)
            elsif t.type == "rock"
                rock = BreakableRock.new(@hero, @camera)
                rock.position = Omega::Vector3.new(t.position.x, t.position.y, 0);
                @list_monsters.push(rock)
            end
        end
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

    def draw_controls
        @text.scale.x = @text.scale.y = 0.5
        @text.text = "Controls:\nX: Attack\nC: Throw brick\nESC: Check quest"
        @text.x = Omega.width - @text.width - 2
        @text.y = Omega.height - @text.height - 7
        @text.z = Hero::UI_Z;
        @text.color = Omega::Color::copy(Omega::Color::BLACK)
        @text.draw

        @text.x -= 2
        @text.y -= 2
        @text.color = Omega::Color::copy(Omega::Color::WHITE)
        @text.draw
    end

end