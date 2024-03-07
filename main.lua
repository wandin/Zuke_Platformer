function love.load()
    love.window.setMode(1280, 768,nil, false)

    gamefont = love.graphics.newFont(20)

        sti = require 'libraries/Simple-Tiled-Implementation/sti'
    cameraFile = require 'libraries/hump/camera'
    anim8 = require('Libraries/anim8/anim8')

    cam = cameraFile()

    sounds = {}
    sounds.jump = love.audio.newSource("sounds/jump.wav", "static")
    sounds.jump:setVolume(0.15)

    sounds.music = love.audio.newSource("sounds/music.mp3", "stream")
    sounds.music:setLooping(true)
    sounds.music:setVolume(0.1)
    sounds.music:play()

    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.background2 = love.graphics.newImage('sprites/background2.png')
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
    sprites.enemySheet = love.graphics.newImage('sprites/enemySheet.png')

    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    local enemyGrid = anim8.newGrid(100, 79, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-15',1), 0.05)
    animations.jump = anim8.newAnimation(grid('1-7',2), 0.05)
    animations.run = anim8.newAnimation(grid('1-15',3), 0.05)
    animations.enemy = anim8.newAnimation(enemyGrid('1-2',1), 0.03)

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0 , 800, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player'--[[, {ignores = {'Platform'}}]])
    world:addCollisionClass('Danger')
    world:addCollisionClass('Enemy')

    require('Player')
    require('Enemy')
    require('libraries/show') -- used to save the data, using the show.lua file

    dangerZone = world:newRectangleCollider(-500, 650, 10000, 500, {collision_class = "Danger"})
    dangerZone:setType('static')


    platforms = {}

    flagX = 0
    flagY = 0

    currentLevel = "level2"

    saveData = {}
    saveData.currentLevel = currentLevel

    if love.filesystem.getInfo("data.lua") then
        local data = love.filesystem.load("data.lua")
        data()
    end

    loadMap(saveData.currentLevel)  
end

function loadMap(mapName)
    saveData.currentLevel = mapName

    love.filesystem.write("data.lua", table.show(saveData, "saveData"))
    destroyAll()

    gameMap = sti("maps/" .. mapName .. ".lua")

    for i, obj in pairs(gameMap.layers["Start"].objects) do
        playerStartX = obj.x
        player.playerStartY = obj.y
    end
    if player.body then 
    player:setPosition(playerStartX, playerStartY)
    end

    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
    for i, obj in pairs(gameMap.layers["Enemies"].objects) do
        spawnEnemy(obj.x, obj.y)
    end
    for i, obj in pairs(gameMap.layers["Flag"].objects) do
        flagX = obj.x
        flagY = obj.y
    end
end

function love.update(deltaTime)

    world:update(deltaTime)
    gameMap:update(deltaTime)
    playerUpdate(deltaTime)
    updateEnemies(deltaTime)

    if player.body then
        local px, py = player:getPosition()
        cam:lookAt(px + 580 , love.graphics.getHeight()/2 - 150)
    end
    
    local colliders = world:queryCircleArea(flagX, flagY, 10, {'Player'})
       if #colliders > 0 then
        if saveData.currentLevel == "level1" then
            loadMap("level2")
        elseif saveData.currentLevel == "level2" then
            loadMap("level1")
        end
    end
end

function love.draw()

    if saveData.currentLevel == "level1" then
        love.graphics.draw(sprites.background, 0 ,0,nil, love.graphics:getWidth() / love.graphics:getWidth() + 0.5, love.graphics.getHeight() / love.graphics.getHeight())
    else
        love.graphics.draw(sprites.background2, 0 ,0,nil, love.graphics:getWidth() / love.graphics:getWidth() + 0.5, love.graphics.getHeight() / love.graphics.getHeight())
    end

    love.graphics.setFont(gamefont)
    love.graphics.print("D - MOVE PARA FRENTE", 200, 10)
    love.graphics.print("A - MOVE PARA TRAS", 200, 30)
    love.graphics.print("SPAÇO - PULA", 200, 50)



    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tiles"])
        --world:draw() -- draw the debug lines
        drawPlayer()
        drawEnemies()
    cam:detach()
end

function love.keypressed(key)
    if key == 'up' or key == 'space' then
        if player.grounded then
            player:applyLinearImpulse(0, -5000)
            sounds.jump:play()
        end
    end
    if key == 'r' then
        loadMap("level2")
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 30, {'Platform', 'Danger'})
        for i,c in ipairs(colliders) do
            c:destroy()
        end
    end
end

function spawnPlatform(x, y, width, height)

     if width > 0 and height > 0 then
      local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
      platform:setType("static")
      table.insert(platforms, platform)
   end
end

function destroyAll()

    local i = #platforms
    while i > -1 do
        if platforms[i] ~= nil then
            platforms[i]:destroy()
        end
        table.remove(platforms, i)
        i = i -1
    end

    local i = #enemies
    while i > -1 do
        if enemies.body and enemies[i] ~= nil then
            enemies[i]:destroy()
        end
        table.remove(enemies, i)
        i = i -1
    end
end