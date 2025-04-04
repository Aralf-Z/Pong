
Push = require "push"

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

    Player1Score = 0
    Player2Score = 0

    Player1Y = 30
    Player2Y = VIRTUAL_HEIGHT - 50

    BallX = VIRTUAL_WIDTH / 2 - 2
    BallY = VIRTUAL_HEIGHT / 2 - 2

    BallDx = math.random(2) == 1 and 100 or  -100
    BallDy = math.random(-50, 50)

    GameState = "start"
end

function love.update(dt)
    if love.keyboard.isDown("w") then
        Player1Y = Player1Y + -PADDLE_SPEED * dt
    elseif love.keyboard.isDown("s") then
        Player1Y = Player1Y + PADDLE_SPEED * dt
    end

    if love.keyboard.isDown("up") then
        Player2Y = Player2Y + - PADDLE_SPEED * dt
    elseif love.keyboard.isDown("down") then
        Player2Y = Player2Y + PADDLE_SPEED * dt
    end 

    if GameState == "play" then
        BallX = BallX + BallDx * dt
        BallY = BallY + BallDy * dt
    end
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

    love.graphics.printf(Player1Y .. "---" .. Player2Y, 0, 40, VIRTUAL_WIDTH, "center")

    --[[
    love.graphics.setFont(ScoreFont)
    love.graphics.print(tostring(Player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(Player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    ]]

    love.graphics.rectangle("fill", 10, 30, 5, 20)

    love.graphics.rectangle("fill", VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20)

    love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4 ,4)

    Push: apply("end")
end