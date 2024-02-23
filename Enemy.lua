enemies = {}

function spawnEnemy(x, y)

    local enemy = world:newRectangleCollider(x, y, 70, 90, {collision_class = "Enemy"})
    enemy.direction = 1
    enemy.speed = 200
    enemy.animation = animations.enemy
    table.insert(enemies, enemy)

end

function updateEnemies(deltaTime)

    for i,enemy in ipairs(enemies) do
        if enemy.body then
            enemy.animation:update(deltaTime)
       
            local ex, ey = enemy:getPosition()

            local colliders = world:queryRectangleArea(ex + (60) * enemy.direction, ey + 40, 10, 10, {"Platform"})
            if #colliders == 0 or enemy:enter("Enemy") then
                enemy.direction = enemy.direction * - 1
            end
            local collidersHigh = world:queryRectangleArea(ex + (60) * enemy.direction, ey -20, 10, 10, {"Platform"})
            if #collidersHigh > 0 then
                enemy.direction = enemy.direction * - 1
            end
            enemy:setX(ex + enemy.speed * deltaTime * enemy.direction)


            local playerSmashCollider = world:queryRectangleArea(ex -35, ey - 70, 70, 10, {"Player"})
            if #playerSmashCollider > 0 then
                enemy:destroy()
            end
        end
    end
end

function drawEnemies()

    for i, enemy in ipairs(enemies) do

        if enemy.body then
            local ex, ey = enemy:getPosition()
            enemy.animation:draw(sprites.enemySheet, ex, ey, nil, enemy.direction, 1, 50, 65)
        end
    end

end