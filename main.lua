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
    LargeFont = love.graphics.newFont("font.ttf", 16)
    ScoreFont = love.graphics.newFont("font.ttf", 32)

    -- Set active font to the smallFont object
    love.graphics.setFont(SmallFont)

    -- Audio Initialize
    Sounds = {
        ["paddle_hit"] = love.audio.newSource("sounds/paddle_hit.wav", "static"),
        ["score"] = love.audio.newSource("sounds/score.wav", "static"),
        ["wall_hit"] = love.audio.newSource("sounds/wall_hit.wav", "static")
    }

    -- Initialize window with virtual resolution
    Push: setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false,
    })

    -- Initialize score
    Player1Score = 0
    Player2Score = 0

    ServingPlayer = 1

    -- Initialize Player1 and Player2
    Player1 = Paddle(10, 30, 5, 20)
    Player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- Initialize the ball
    TheBall = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    GameState = "start"
end

function love.resize(w, h)
    Push: resize(w, h)
end

function love.update(dt)
    -- Collides
    if GameState == "serve" then
        TheBall.dy = math.random(-50, 50)
        if ServingPlayer == 1 then
            TheBall.dx = math.random(140, 200)
        else
            TheBall.dx = -math.random(140, 200)
        end
    end
    if GameState == "play" then
        if TheBall: collides(Player1) then
            TheBall.dx = - TheBall.dx * 1.03
            TheBall.x = Player1.x + 5
            if TheBall.dy < 0 then
                TheBall.dy = -math.random(10, 150)
            else
                TheBall.dy = math.random(10, 150)
            end

            Sounds["paddle_hit"]: play()
        end

        if TheBall: collides(Player2) then
            TheBall.dx = - TheBall.dx * 1.03
            TheBall.x = Player2.x - 4

            if TheBall.dy < 0 then
                TheBall.dy = -math.random(10, 150)
            else
                TheBall.dy = math.random(10, 150)
            end

            Sounds["paddle_hit"]: play()
        end

        if TheBall.y <= 0 then
            TheBall.y = 0
            TheBall.dy = - TheBall.dy

            Sounds["wall_hit"]: play()
        end

        if TheBall.y >= VIRTUAL_HEIGHT - 4 then
            TheBall.y = VIRTUAL_HEIGHT - 4
            TheBall.dy = -TheBall.dy

            Sounds["wall_hit"]: play()
        end

        -- Score
        if TheBall.x < 0 then
            ServingPlayer = 1
            Player2Score = Player2Score + 1

            Sounds["score"]: play()

            if Player2Score == 5 then
                WinningPlayer = 2
                GameState = "done"
            else
                TheBall: reset()
                GameState = "serve"
            end
        end

        if TheBall.x > VIRTUAL_WIDTH then
            ServingPlayer = 2
            Player1Score = Player1Score + 1

            Sounds["score"]: play()

            if Player1Score == 5 then
                WinningPlayer = 1
                GameState = "done"
            else
                TheBall: reset()
                GameState = "serve"
            end
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
            GameState = "serve"
        elseif GameState == "serve" then
            GameState = "play"
        elseif GameState == "done" then
            GameState = "serve"

            TheBall: reset()

            Player1Score = 0
            Player2Score = 0

            if WinningPlayer == 1 then
                ServingPlayer = 2
            else
                ServingPlayer = 1
            end
        end
    end
end

function love.draw()
    -- Begin rendering at virtual resolution
    Push: start()

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

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
        love.graphics.printf("Hello Start State!", 0, 10, VIRTUAL_WIDTH, "center")
        love.graphics.printf("Press Enter to begin!", 0, 20, VIRTUAL_WIDTH, "center")
    elseif GameState == "serve" then
        love.graphics.printf("Player" .. tostring(ServingPlayer) .. "'s serve", 0, 10, VIRTUAL_WIDTH, "center")
        love.graphics.printf("Press Enter to serve!", 0, 20, VIRTUAL_WIDTH, "center")
    elseif GameState == "play" then

    elseif GameState == "done" then
        love.graphics.setFont(LargeFont)
        love.graphics.printf("Player" .. tostring(WinningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, "center")
        love.graphics.setFont(SmallFont)
        love.graphics.printf("Press Enter to restart!", 0, 30, VIRTUAL_WIDTH, "center")
    end

    DisplayScore()

    Player1: render()
    Player2: render()

    TheBall: render()

    DisplayFPS()

    Push: finish()
end

function DisplayFPS()
    love.graphics.setFont(SmallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
end


function DisplayScore()
    love.graphics.setFont(ScoreFont)
    love.graphics.print(tostring(Player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(Player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end