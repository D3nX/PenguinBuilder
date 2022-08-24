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
            if @cursor.block_id == i
                @itembox.x = x
                @itembox.y = Omega.height - @itembox.height - 10
                @itembox.z = UI_Z + 100
                @itembox.set_scale(1.0, 1.1)
                @itembox.color = Omega::Color::copy(Omega::Color::RED)
                @itembox.color = Omega::Color.new(0, 0, 0) if $inventory[IsoMap::BlockNames[i]] == 0

                @itembox.draw

                @itembox.z = 0
                @itembox.set_scale(1)
                @itembox.color = Omega::Color::copy(Omega::Color::WHITE)
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
            image.draw(icon_pos.x, icon_pos.y, UI_Z + 100, scale, scale)

            color = ($inventory[IsoMap::BlockNames[i]] == 0) ? Gosu::Color::RED : Gosu::Color::WHITE
            $font.draw_text("#{$inventory[IsoMap::BlockNames[i]]}", x + 5, @itembox.y + 2, UI_Z + 100, 0.5, 0.5, color)

            x += @size
        end
    end

end
