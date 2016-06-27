
--[[---------------------------------------------------------------------------\
|   @scebe mainScene                                                           |
|   romansharf - 5/10/16/05/2016                                               |
-------------------------------------------------------------------------------|
| This is the main scene of the admin. This scene serves as the top level      |
| user interface or canvas for the admin                                       |
\-----------------------------------------------------------------------------]]

--local database = require('scripts.database')
--local db = database:getInstance()

local composer = require("composer")
local widget = require("widget")
local mainScene = composer.newScene()
local constants = require("constants")
local scenarioMenu = require('scripts.scenarioMenu')
local slideNode = require('scripts.slideNode')
local menuBarClass = require('scripts.menuBar')
local curve = require('scripts.curve')
local util = require('scripts.lib.utils')


-- Forward Method delcarations
local createSlideNode
local createAdminScenarioButton
local createAdminSlideButton
local onTouchEvent
local createBackground
local bgDragHandler

-- Forward var declarations
local sceneGroup
local menuBar
local bg_grp


function mainScene:create( event )
    
    sceneGroup = self.view

    -- Create a background and a background group
    bg_grp = createBackground()
  

    print (scenarioMenu.test)
    -- Create a new scenario drop down menu
    --local menu = scenarioMenu.new(20, 20)

    local adminScenarioButton = createAdminScenarioButton()
    local adminSlideButton = createAdminSlideButton()

    Runtime:addEventListener('touch', onTouchEvent)

    -- Insert the background group into the sceneGroup
    sceneGroup:insert(bg_grp)

    sceneGroup:insert(adminSlideButton)
    sceneGroup:insert(adminScenarioButton)


    -- Initialize the menu bar
    menuBar = menuBarClass.init(sceneGroup)
end

-- Listener setup
mainScene:addEventListener( "create", mainScene)

--[[-------------------------------------------\
| Private methods                              |
\---------------------------------------------]]

function createBackground()
    
    local group = display.newGroup()

    local x, y = display.contentCenterX, display.contentCenterY
    local scale = 0.1
    local bg = display.newRect(x,y, 2048, 2048)
    display.setDefault('textureWrapX', 'repeat')
    display.setDefault('textureWrapY', 'repeat')

    util.setAnchors(bg, 0.5, 0.5)
    bg.fill = { type='image', filename='assets/images/grid5.jpg'}
    bg.fill.scaleX = scale
    bg.fill.scaleY = scale
    bg.group = group
    group:insert(bg)
    
    -- Used for clamping the dragging of the bg
    bg.clampX = bg.width/4
    bg.clampY = bg.height/4

    bg:addEventListener('touch', bgDragHandler)

    return group
end

-- Functionality for Moving the background around
function bgDragHandler(event)
    local bg = event.target
    local group = bg.group

    if (event.phase == "began") then

        display.getCurrentStage():setFocus( bg, event.id )
        bg.isFocus = true

        --print ('touch')

        group.markX = group.x
        group.markY = group.y

    elseif (bg.isFocus) then

        if (event.phase == "moved") then
    

            local groupX = (event.x - event.xStart) + group.markX
            local groupY = (event.y - event.yStart) + group.markY

            group.x = groupX
            group.y = groupY

             -- Clamp horizontal BG dragging
            if (group.x < -bg.clampX) then
                group.x = -bg.clampX
            elseif(group.x > bg.clampX) then
                group.x = bg.clampX
            end

            -- Clamp vertical BG dragging
            if (group.y < -bg.clampY) then
                group.y = -bg.clampY
            elseif(group.y > bg.clampY) then
                group.y = bg.clampY
            end



        elseif (event.phase == "ended" or event.phase == "cancelled") then
            display.getCurrentStage():setFocus(bg, nil)
            bg.isFocus = false
        end
    end
    
    return true
end

function onTouchEvent(event)
--     if (event.phase == 'began') then
--         print ('tap')
--     end
 end

function createAdminScenarioButton()
    local button = widget.newButton({
        left = 20,
        top = 80,
        width = 180,
        height = 50,
        fontSize = 20,
        shape = "roundedRect",
        --id = "button1",
        label = "Create Scenario",
        onRelease = function ()
            print("tapped")
        end
    })
    button:setFillColor(0,0,0)

    return button
end

-- createAdminSlideButton
function createAdminSlideButton()
    local button = widget.newButton({
        left = 20,
        top = 150,
        width = 180,
        height = 50,
        fontSize = 20,
        shape = "roundedRect",
        --id = "button1",
        label = "Create Slide",
        onRelease = createSlideNode
    })
    button:setFillColor(0,0,0)
    return button
end

-- createSlideNode
function createSlideNode ()
    slideNode.new(bg_grp)
end

return mainScene