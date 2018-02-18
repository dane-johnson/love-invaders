local suit = require("suit")

love.graphics.setDefaultFilter('nearest', 'nearest')
enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
enemies_controller.image = love.graphics.newImage('invader.png')

function check_collisions(enemies, bullets)
   for i, e in ipairs(enemies) do
      for j, b in ipairs(bullets) do
         if b.y <= e.y + e.height and b.y > e.y and b.x > e.x and b.x < e.x + e.width then
            table.remove(enemies, i)
            table.remove(bullets, j)
            enemies_controller.speed = enemies_controller.speed + 0.3
         end
      end
   end
end


function love.load()
   pregame = true
   background = love.graphics.newImage('background.png')
   player = {}
   player.x = 0
   player.y = 550
   player.bullets = {}
   player.cooldown = 20
   player.speed = 10
   player.image = love.graphics.newImage('player.png')
   player.fire_sound = love.audio.newSource('lazer.wav')
   player.fire = function()
      if player.cooldown <= 0 then
         love.audio.play(player.fire_sound)
         player.cooldown = 20
         bullet = {}
         bullet.x = player.x + 11
         bullet.y = player.y
         table.insert(player.bullets, bullet)   
       end
   end
   for i = 0, 6 do
      for j = 0, 2 do
         enemies_controller:spawn_enemy(i * 80, j * 40)
      end
   end
   enemies_controller.direction = "right"
   enemies_controller.speed = 0.2
end

function enemies_controller:spawn_enemy(x, y)
   enemy = {}
   enemy.x = x
   enemy.y = y
   enemy.width = 32
   enemy.height = 32
   enemy.bullets = {}
   enemy.cooldown = 20
   table.insert(self.enemies, enemy)
end

function enemies_controller:set_directions()
   if self.direction == "right" then
      for _,e in pairs(self.enemies) do
         if e.x >= 800 - e.width then
            self.direction = "left"
            self:decend()
         end
      end
   elseif self.direction == "left" then
      for _,e in pairs(self.enemies) do
         if e.x <= 0 then
            self.direction = "right"
            self:decend()
         end
      end
   end
end

function enemies_controller:decend()
   for _,e in pairs(self.enemies) do
      e.y = e.y + e.height
   end
end


function enemy:fire()
   if self.cooldown <= 0 then
      self.cooldown = 20
      bullet = {}
      bullet.x = self.x + 35
      bullet.y = self.y
      table.insert(self.bullets, bullet)
   end
end


function love.update(dt)
   if pregame then
      suit.layout:reset(100, 100)
      suit.layout:padding(10, 10)
      if suit.Button("Start Game!", suit.layout:row(300, 30)).hit then
         pregame = false
      end
      if suit.Button("Quit", suit.layout:row()).hit then
         love.event.quit()
      end
   else
      player.cooldown = player.cooldown - 1
      if love.keyboard.isDown("right") then
         player.x = player.x + player.speed
      elseif love.keyboard.isDown("left") then
         player.x = player.x - player.speed
      end

      if love.keyboard.isDown("space") then
         player.fire()
      end

      enemies_controller:set_directions()

      for _, e in pairs(enemies_controller.enemies) do
         if enemies_controller.direction == "right" then
            e.x = e.x + enemies_controller.speed
         elseif enemies_controller.direction == "left" then
            e.x = e.x - enemies_controller.speed
         end
         if e.y + e.height >= love.graphics.getHeight() then
            game_over = true
         end
      end

      for i,b in ipairs(player.bullets) do
         if b.y < -10 then
            table.remove(player.bullets, i)
         end
         b.y = b.y - 10
      end
      check_collisions(enemies_controller.enemies, player.bullets)
      if #enemies_controller.enemies == 0 then
         game_win = true
      end
   end
end

function love.draw()
   if pregame then
      -- pass
   elseif game_over then
      love.graphics.print("Game Over!")
   elseif game_win then
      love.graphics.print("You win!")
   else
      love.graphics.draw(background, 0, 0, 0, 2)
      -- draw the player
      love.graphics.setColor(0, 0, 255)
      love.graphics.draw(player.image, player.x, player.y, 0, 2)

      -- draw enemies
      love.graphics.setColor(255, 255, 255)
      for _,e in pairs(enemies_controller.enemies) do
         love.graphics.draw(enemies_controller.image, e.x, e.y, 0, 1)
      end
      
      -- draw bullets
      love.graphics.setColor(255, 255, 255)
      for _, v in pairs(player.bullets) do
         love.graphics.rectangle("fill", v.x, v.y, 10, 10)
      end
   end
   suit.draw()
end
