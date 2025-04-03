
Push = require "push"

WINDOW_WIDTH = 180
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    local smallFont = love.graphics.newFont("font.ttf", 8)
    love.graphics.setFont(smallFont)

    Push: setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end


function love.draw()

    Push: apply("start")

    --love.graphics.clear(40,/255, 45/255, 52/255, 255/255, true, true)

    love.graphics.clear()

    love.graphics.printf(
        "Hello Pong!",
        0,
        VIRTUAL_HEIGHT / 2 - 6,
        VIRTUAL_WIDTH,
        "center"
    )

    love.graphics.rectangle("fill", 10, 30, 5, 20)

    love.graphics.rectangle("fill", VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20)

    love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4 ,4)

    Push: apply("end")
end