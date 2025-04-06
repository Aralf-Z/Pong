--[[
    push is a library that will allow us to draw our game at a virtual resolution, instead of however large our window is; used to provide a more retro aesthetic

    https://github.com/Ulydev/push
]]
Push = require "push"

--[[
    the "Class" library we're using will allow us to represent anything in our game as code, rather than keeping track of many disparate variables and methods

    https://github.com/vrld/hump/blob/master/class.lua
]]
Class = require "class"

--[[
    the paddle class that players control
]]
require "Paddle"

--[[
    the ball class that players hit with paddles
]]
require "Ball"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    -- Sets the default scaling filters used with Images, Canvases, and Fonts.
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Set the title of our application window
    love.window.setTitle("Pong")

    math.randomseed(os.time())

    SmallFont = love.graphics.newFont("font.ttf", 8)
    ScoreFont = love.graphics.newFont("font.ttf", 32)

    -- Set active font to the smallFont object
    love.graphics.setFont(SmallFont)

    -- Initialize window with virtual resolution
    Push: setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- Initialize score
    Player1Score = 0
    Player2Score = 0

    -- Initialize Player1 and Player2
    Player1 = Paddle(10, 30, 5, 20)
    Player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- Initialize the ball
    TheBall = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    GameState = "start"
end

function love.update(dt)
    -- Collides
    if GameState == "play" then
        if TheBall: collides(Player1) then
            TheBall.dx = - TheBall.dx * 1.03
            TheBall.x = Player1.x + 5
            if TheBall.dy < 0 then
                TheBall.dy = -math.random(10, 150)
            else
                TheBall.dy = math.random(10, 150)
            end
        end

        if TheBall: collides(Player2) then
            TheBall.dx = - TheBall.dx * 1.03
            TheBall.x = Player2.x - 4

            if TheBall.dy < 0 then
                TheBall.dy = -math.random(10, 150)
            else
                TheBall.dy = math.random(10, 150)
            end
        end

        if TheBall.y <= 0 then
            TheBall.y = 0
            TheBall.dy = - TheBall.dy
        end

        if TheBall.y >= VIRTUAL_HEIGHT - 4 then
            TheBall.y = VIRTUAL_HEIGHT - 4
            TheBall.dy = -TheBall.dy
        end
    end

    -- Player1 movement
    if love.keyboard.isDown("w") then
        Player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("s") then
        Player1.dy = PADDLE_SPEED
    else
        Player1.dy = 0
    end

    -- Player2 movement
    if love.keyboard.isDown("up") then
        Player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("down") then
        Player2.dy = PADDLE_SPEED
    else
        Player2.dy = 0
    end

    -- TheBall movement
    if GameState == "play" then
        TheBall: update(dt)
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

            TheBall: reset()
        end
    end
end

function love.draw()
    -- Begin rendering at virtual resolution
    Push: apply("start")

    --love.graphics.clear(40,/255, 45/255, 52/255, 255/255)
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

    -- GamseState On UI
    love.graphics.setFont(SmallFont)
    if GameState == "start" then
        love.graphics.printf("Hello Start State!", 0, 20, VIRTUAL_WIDTH, "center")
    elseif GameState == "play" then
        love.graphics.printf("Hello Play State!", 0, 20, VIRTUAL_WIDTH, "center")
    end

    -- Scores of Players
    love.graphics.setFont(ScoreFont)
    love.graphics.print(tostring(Player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(Player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    Player1: render()
    Player2: render()

    TheBall: render()

    DisplayFPS()

    Push: apply("end")
end

function DisplayFPS()
    love.graphics.setFont(SmallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end