    playerStartX = 100
    playerStartY = 100
    -- Player
    player = world:newRectangleCollider(playerStartX, playerStartY, 40, 120, {collision_class = 'Player'})
    player:setFixedRotation(true)
    player.speed = 240
    player.animation = animations.idle
    player.isMoving = false
    player.direction = 1
    player.grounded = true

    function playerUpdate(deltaTime)

        if player.body then

            local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 60, 40, 3, {'Platform', 'Enemy'})
    
            if #colliders > 0 then
                player.grounded = true 
            else 
                player.grounded = false
            end            
    
            player.isMoving = false
    
            local px, py = player:getPosition()
    
            if love.keyboard.isDown('d') then
                player:setX(px + player.speed * deltaTime)
                player.isMoving = true
                player.direction = 1
            end
    
    
            if love.keyboard.isDown('a') then
                player:setX(px - player.speed * deltaTime)
                player.isMoving = true
                player.direction = -1
            end
    
            if player:enter('Danger') or player:enter('Enemy') then player:setPosition(playerStartX, playerStartY) end
    
        end
    
            if player.grounded then
        
                if player.isMoving then player.animation = animations.run else player.animation = animations.idle end
            else
                player.animation = animations.jump
            end
    
        player.animation:update(deltaTime)
    end

    function drawPlayer()

        if player.body then
            local px, py = player:getPosition()
            player.animation:draw(sprites.playerSheet, px, py, nil, 0.25 * player.direction, 0.25, 130, 260)
        end
    end