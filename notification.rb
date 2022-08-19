class Notification < Omega::Sprite

    def initialize()
        super("assets/notification.png")
        @messages = []
        @text = Omega::Text.new("", Gosu::Font.new(60))
        @launched = false
        @timer = 0
        @timer_max = 200

        set_scale(2)
        set_position(Omega.width - self.width_scaled, -self.height_scaled, 1000)
    end

    def launch(messages, timer_max = 200)
        @messages = messages
        @launched = true
        @timer_max = timer_max
        @timer = timer_max
    end

    def draw
        return if not @launched
        super()

        if @timer > 0
            @position.y += 3 if @launched and @position.y < 0
            @position.y = 0 if @position.y > 0
        else
            @position.y -= 3 if @launched and @position.y > -self.height_scaled
            @position.y = -self.height_scaled if @position.y < -self.height_scaled
            if @position.y == -self.height_scaled
                @messages.shift
                if @messages.size > 0
                    @timer = 200
                else
                    @launched = false
                end
            end
        end

        @timer -= (@timer > 0) ? 1 : 0

        @text.text = @messages[0]
        @text.scale = Omega::Vector2.new(0.7, 0.7)
        @text.position = Omega::Vector3.new((Omega.width - @text.width) / 2, @position.y + 10, @position.z)
        @text.draw()
    end

end
