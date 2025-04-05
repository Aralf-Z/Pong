--[[

    main.lua

]]

--[[
    push is a library that will allow us to draw our game at a virtual
    resolution, instead of however large our window is; used to provide
    a more retro aesthetic

    https://github.com/Ulydev/push
]]
Push = require "push"

--[[
    the "Class" library we're using will allow us to represent anything in our game as code, rather than keeping track of many disparate variables and methods

    https://github.com/vrld/hump/blob/master/class.lua
]]
Class = require "class"

require "Paddle"
require "Ball"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    math.randomseed(os.time())

    SmallFont = love.graphics.newFont("font.ttf", 8)
    ScoreFont = love.graphics.newFont("font.ttf", 32)

    love.graphics.setFont(SmallFont)

    Push: setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    Player1 = Paddle(10, 30, 5, 20)
    Player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    GameState = "start"
end

function love.update(dt)
    if love.keyboard.isDown("w") then
        Player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("s") then
        Player1.dy = PADDLE_SPEED
    else
        Player1.dy = 0
    end

    if love.keyboard.isDown("up") then
        Player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("down") then
        Player2.dy = PADDLE_SPEED
    else
        Player2.dy = 0
    end

    if GameState == "play" then
        ball: update(dt)
    end

    Player1: update(dt)
    Player2: update(dt)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "enter" or key == "return" then
        if GameState == "start" then
            GameState = "play"
        else
            GameState = "start"

            BallX = VIRTUAL_WIDTH / 2 - 2
            BallY = VIRTUAL_HEIGHT / 2 - 2

            BallDx = math.random(2) == 1 and 100 or -100
            BallDy = math.random(-50, 50) * 1.5
        end
    end
end

function love.draw()

    Push: apply("start")

    --love.graphics.clear(40,/255, 45/255, 52/255, 255/255, true, true)
    love.graphics.clear()

    --[[
    love.graphics.printf(
        "Hello Pong!",
        0,
        VIRTUAL_HEIGHT / 2 - 6,
        VIRTUAL_WIDTH,
        "center"
    )
    ]]

    love.graphics.setFont(SmallFont)
    if GameState == "start" then
        love.graphics.printf("Hello Start State!", 0, 20, VIRTUAL_WIDTH, "center")
    elseif GameState == "play" then
        love.graphics.printf("Hello Play State!", 0, 20, VIRTUAL_WIDTH, "center")
    end

    --[[
    love.graphics.setFont(ScoreFont)
    love.graphics.print(tostring(Player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(Player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    ]]

    Player1: render()
    Player2: render()

    ball: render()

    Push: apply("end")
end