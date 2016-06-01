
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


-- Forward var declarations
local sceneGroup
local menuBar
local bg


function mainScene:create( event )
    
    sceneGroup = self.view

    bg = createBackground()

    -- Initialize the menu bar
    print (scenarioMenu.test)
    -- Create a new scenario drop down menu
    --local menu = scenarioMenu.new(20, 20)

    local adminScenarioButton = createAdminScenarioButton()
    local adminSlideButton = createAdminSlideButton()

    sceneGroup:insert(adminScenarioButton)
    --sceneGroup:insert(menu.menu)
    menuBar = menuBarClass.init(sceneGroup)

    Runtime:addEventListener('touch', onTouchEvent)
end

-- Listener setup
mainScene:addEventListener( "create", mainScene)

--[[-------------------------------------------\
| Private methods                              |
\---------------------------------------------]]

function createBackground()
    local x, y = display.contentCenterX, display.contentCenterY
    local scale = 0.1
    local bg = display.newRect(x,y, 2048, 2048)
    display.setDefault('textureWrapX', 'repeat')
    display.setDefault( 'textureWrapY', 'repeat')

    util.setAnchors(bg, 0.5, 0.5)
    bg.fill = { type='image', filename='assets/images/grid5.jpg'}
    bg.fill.scaleX = scale
    bg.fill.scaleY = scale
    sceneGroup:insert(bg)
    return bg
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

    sceneGroup:insert(button)

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

    sceneGroup:insert(button)

    return button
end

-- createSlideNode
function createSlideNode ()
    slideNode.new(sceneGroup)
end



return mainScene