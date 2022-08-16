class ItemMenu

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

        @itembox.z = 1000
        for i in 0...IsoMap::BlockNames.size
            if @cursor.block_id == i
                @itembox.x = x
                @itembox.y = Omega.height - @itembox.height - 10
                @itembox.z = 1000
                @itembox.set_scale(1.0, 1.1)
                @itembox.color = Omega::Color::copy(Omega::Color::RED)

                @itembox.draw

                @itembox.z = 0
                @itembox.set_scale(1)
                @itembox.color = Omega::Color::copy(Omega::Color::WHITE)
            else
                @itembox.x = x
                @itembox.y = Omega.height - @itembox.height - 5
                @itembox.draw
            end

            image = @isomap.tileset[i]
            scale = 2.4
            icon_pos = Omega::Vector2.new(@itembox.x + (@itembox.width_scaled - image.width * scale) / 2,
                                            @itembox.y + (@itembox.height_scaled - image.height * scale) / 2)
            image.draw(icon_pos.x, icon_pos.y, 1000, scale, scale)

            x += @size
        end
    end

end
