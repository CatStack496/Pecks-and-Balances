function love.conf(t)
	t.window.width = 800
	t.window.height = 800
	t.window.resizable = false
	t.accelerometerjoystick = false
  	t.modules.joystick = false
  	t.modules.physics = false
  	t.title = "Pecks and Balances"
	t.window.icon = "textures/icon.png"
end