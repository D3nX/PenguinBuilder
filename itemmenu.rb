class ItemMenu

    UI_Z = 100_000

    def initialize(isomap, cursor)
        @itembox = Omega::Sprite.new("assets/itembox.png")
        @border = 2
        @size = @itembox.width - @border
        @isomap = isomap
        @cursor = cursor
    end

    def draw
        total_width = @size * IsoMap::BlockNames.size
        x = (Omega.width - total_width) / 2

        @itembox.z = UI_Z
        for i in 0...IsoMap::BlockNames.size
            quantity = $inventory[IsoMap::BlockNames[i]];

            if @cursor.block_id == i
                @itembox.x = x
                @itembox.y = Omega.height - @itembox.height - 10
                @itembox.z = UI_Z + 100
                @itembox.set_scale(1.0, 1.1)
                @itembox.color = Omega::Color::copy((quantity <= 0) ? Omega::Color::RED : Omega::Color::WHITE)
                @itembox.draw

                @itembox.z = 0
                @itembox.set_scale(1)
                @itembox.color = Omega::Color::copy(Gosu::Color.new(90,0,0,0))
            else
                @itembox.x = x
                @itembox.y = Omega.height - @itembox.height - 5
                @itembox.z = UI_Z
                @itembox.color = Omega::Color::copy(Omega::Color::WHITE)
                @itembox.color = Omega::Color::copy(Omega::Color::GRAY) if $inventory[IsoMap::BlockNames[i]] == 0

                @itembox.draw
            end

            image = @isomap.tileset[i]
            scale = 2.4
            icon_pos = Omega::Vector2.new(@itembox.x + (@itembox.width_scaled - image.width * scale) / 2,
                                            @itembox.y + (@itembox.height_scaled - image.height * scale) / 2)
            image.draw(icon_pos.x, icon_pos.y, UI_Z + 100, scale, scale, (quantity <= 0) ? Gosu::Color.new(90,90,90,90) : Gosu::Color::WHITE)
            $font.draw_text("#{quantity}", x + 5, @itembox.y + 2, UI_Z + 100, 0.5, 0.5, (quantity <= 0) ? Gosu::Color::YELLOW : Gosu::Color::WHITE)
            x += @size
        end
    end

end
