anim8 = require 'libraries/anim8'
json = require 'libraries/json'
require('libraries/randomlua')
mwc = mwc(os.time())
require('libraries/catlib')

function saveSG(data)
    love.filesystem.write("savegame.json", json.encode(data))
end
function loadSG()    
    if love.filesystem.getInfo('savegame.json') == nil then
        local data = {day = 1, population = 10000, economyH = 0, ecologyH = 0, politicSupport = 0}
        saveSG(data)
    end
    -- Load the data table:
    -- Copy the variables out of the table:
    return json.decode(love.filesystem.read("savegame.json"))
end

RAW_objects = json.decode(love.filesystem.read("objects.json"))
objects = json.decode(love.filesystem.read("objects.json"))
RAW_font = json.decode(love.filesystem.read("fonts.json"))
font = json.decode(love.filesystem.read("fonts.json"))
RAW_sounds = json.decode(love.filesystem.read("audio.json"))
sounds = json.decode(love.filesystem.read("audio.json"))
saveData = loadSG()
prompts = json.decode(love.filesystem.read("prompts2.json"))

function love.load()
    loadFonts()
    love.graphics.setDefaultFilter("nearest", "nearest")
    loadObjects()
    loadSounds()
    WIDTH, HEIGHT, FLAGS = love.window.getMode()
    --print(HEIGHT)
    isMoving = false
    points = 0
    stage = 0
    
    --love.graphics.setFont(font)
    currentState = "titleScreen"
    states = {}
    function states.gameOver()
        currentState = "gameOver"
    end
    function states.gameActive()
        currentState = "gameActive"
        timer2 = 0
        paperActive = false
        chosePrompt = false
        prompt = 0
    end
    function states.titleScreen()
        currentState = "titleScreen"
        --catlib.setFontSize("RM_bold", 24)
        clicked = false
        fadeout=nil
        timer1 = 0
        radius = 0
        playSound = false
        textBlink = textBlink or 1
        logo_fadeout = 1
    end
    function states.startUp()
        currentState = "startUp"
        timer1 = 0
        fadeout = 1
        catlib.setFontSize("RM_bold", 20)
        textBlink = 1
        textBlinkMin = false
        sounds.title_ambient:setVolume(0)
        logo_fadeout = 1
    end
    states.startUp()
end

--function love.keypressed(key)
--    if key == "1" then
--        --states.gameActive()
--        --love.window.setFullscreen(not FLAGS.fullscreen)
--        love.window.setMode(350, 350)
--        refreshWindowValues()
--    end
--end

function love.update(dt)
    WIDTH, HEIGHT, FLAGS = love.window.getMode()
    if currentState == "gameActive" then
        objects["fax"]["animation"]["ANIM"]:update(dt)
        timer2 = timer2 + dt
        if timer2 >= 5 then
            objects["fax"]["animation"]["ANIM"]:gotoFrame(1)
            objects["fax"]["animation"]["ANIM"]:resume()
        end
        if timer2 >= 7.4 then
            if not chosePrompt then
                prompt = catlib.getRandPrompt(prompts)
                chosePrompt = true
                paperActive = true
            end
        end
    end
    if currentState == "gameOver" then
    end
    if currentState == "titleScreen" or currentState == "startUp" then
        nextParallaxFrame(dt, objects["title_sky2"])
        catlib.loopAudio(sounds.title_ambient)
        local time = dt
        if textBlink > 1 then
            textBlink = 1
            textBlinkMin = false
        elseif textBlink <0.3 then
            textBlink = 0.3
            textBlinkMin = true
        end
        if not textBlinkMin then time = dt * -1 end
        textBlink = textBlink + (time /1.5)
        
    end
    if currentState == "startUp" then
        timer1 = timer1 + dt
        if timer1 >= 7 then
            fadeout = fadeout - (dt/2)
            sounds.title_ambient:setVolume((timer1 - 7)/2)
        end
        if fadeout < 0 then
            sounds.title_ambient:setVolume(1)
            states.titleScreen()
        end
    end
    if currentState == "titleScreen" then
        if clicked then
            timer1 = timer1 + dt
            radius = radius + (dt*(400+(radius * 5))*gameScale)
            if timer1 >= 2 then
                logo_fadeout = logo_fadeout - (dt/0.9)
                sounds.title_ambient:setVolume(1-((timer1 - 2)/0.9))
            end
            if logo_fadeout < 0 then
                sounds.title_ambient:setVolume(0)
                love.audio.stop(sounds.title_ambient)
                logo_fadeout = 0
                states.gameActive()
                logo_fadeout = nil
                timer1 = nil
                radius = nil
                clicked = nil
                playsound = nil
            end
        end
    end
    if love.mouse.isDown(1) then
        local x, y = love.mouse.getPosition( )
        if currentState == "gameActive" then
            if paperActive then
                if x > (windowWidth/2) then
                    timer2 = 0
                    paperActive = false
                    chosePrompt = false
                    
                    stage = stage + 1
                else
                    timer2 = 0
                    paperActive = false
                    chosePrompt = false
                    
                    stage = stage + 1
                end
            end
        end
        if currentState == "gameOver" then
        end
        if currentState == "titleScreen" then
            clicked = true
            if clicked and not playSound then
                love.audio.play(sounds.game_start)
                playsound = true
            end
        end
	end	
end

function love.draw()
    if currentState == "titleScreen" or currentState == "startUp" then
        objects["title_sky1"]:drawObject()
        objects["title_sky2"]:drawObject()
        objects["chad_statue_title"]:drawObject()
        catlib.printf(0,0,0,textBlink,"Click anywhere to start day " .. saveData.day .. "!", font.QS_regular ,objects["logo"]["coords"][1][1], objects["logo"]["coords"][1][2] + ((objects["logo"]["texture"]:getHeight() * gameScale)*2) ,(objects["logo"]["texture"]:getWidth() * gameScale) * 2,"center")
        if clicked then
            catlib.drawShape("circle",0,0,0,1,"fill",objects["logo"]["coords"][1][1] +((objects["logo"]["texture"]:getWidth() * objects["logo"]["scale"])/2),objects["logo"]["coords"][1][2] + ((objects["logo"]["texture"]:getHeight() * objects["logo"]["scale"])/2),radius)
        end
        objects["logo"]:drawObject(1,1,1,logo_fadeout)
        --objects["faxStand"]:drawObject()
        --objects["fax"]:drawObject(1,1,1,1,0,0,0,objects["fax"]["scale"])
    end
    if currentState == "startUp" then
        catlib.drawShape("rectangle",0,0,0,fadeout,"fill", 0,0, windowWidth,windowHeight)
        catlib.printf(1,1,1,fadeout,"This guy made it to office through sheer strength, charisma, and good looks, and now has to take advice from anyone who will give it to keep the country running", font.RM_bold ,(windowWidth / 2) - math.floor((windowWidth /1.2)/2), (windowHeight / 2) - math.floor((windowHeight /2)/6) ,windowWidth /1.2,"center")
    end
    if currentState == "gameActive" then
        if stage == 0 then
            objects["stage0"]:drawObject(1,1,1,1,0,50,0,objects["stage0"]["scale"])
        elseif stage == 1 then
            objects["stageMax1"]:drawObject(1,1,1,1,0,50,0,objects["stageMax1"]["scale"])
        elseif stage == 2 then
            objects["stageMax2"]:drawObject(1,1,1,1,0,50,0,objects["stageMax2"]["scale"])
        elseif stage == 3 then
            objects["stageMax3"]:drawObject(1,1,1,1,0,50,0,objects["stageMax3"]["scale"])
        elseif stage == -1 then
            objects["stageMin1"]:drawObject(1,1,1,1,0,50,0,objects["stageMin1"]["scale"])
        elseif stage == -2 then
            objects["stageMin2"]:drawObject(1,1,1,1,0,50,0,objects["stageMin2"]["scale"])
        elseif stage == -3 then
            objects["stageMin3"]:drawObject(1,1,1,1,0,50,0,objects["stageMin3"]["scale"])
        end
        objects["faxStand"]:drawObject(1,1,1,1,windowWidth/2-(objects["faxStand"]["texture"]:getWidth() / 2), 0,0,objects["faxStand"]["scale"])
        objects["fax"]:drawObject(1,1,1,1,windowWidth/2-(objects["faxStand"]["texture"]:getWidth() / 2), 0,0,objects["fax"]["scale"])

        if paperActive then
            objects["paper"]:drawObject(1,1,1,1,0 + 100, 0,0,objects["paper"]["scale"])
            catlib.printf(0,0,0,1,prompts[prompt]["text"], font.RM_bold ,(windowWidth / 2) - math.floor((windowWidth /2)/2), 30 ,windowWidth /2,"left")
            catlib.printf(0,0,0,1,"click on the left or right side of the screen to choose yes or no respectfully", font.RM_bold ,(windowWidth / 2) - math.floor((windowWidth /2)/2), windowHeight -170 ,windowWidth /2,"left")
        end 
        
    end
    --objects["bird"]["animation"]["ANIM"]:draw(objects["bird"]["texture"], objects["bird"]["coords"][1][1], objects["bird"]["coords"][1][2], (objects["bird"]["animation"]["velocity"]) * -0.05, objects["bird"]["scale"], objects["bird"]["scale"])
end
