--[[----------------------------------------------------------------------------
|   @class slideNode
|   romansharf - 5/3/16/05/2016                                                        |
-------------------------------------------------------------------------------|            
| Class that controls the creation and updating of slideNodes                                                                             |
------------------------------------------------------------------------------]]

local constants = require("constants")
local widget = require("widget")
local curve = require('scripts.curve')

local slideNode = {}
local slideNode_mt = { __index = slideNode }

local slideNodes = {}               -- All slide nodes

-- Method forward delclarations
local nodeTouchListener
local createOutputCirlce
local createInputCircle
local outputCircleHandler
local endCapHandler
local drawCurve
local createTitle

local circleImageSheetOptions = {
    width = 18,
    height = 18,
    numFrames = 2,
    sheetContentWidth = 36,
    sheetContentHeight = 18
}

-- Variable forward delclarations


function slideNode.new(sceneGroup)

    local instance = {}

    -- Container for all elements in the slide node
    local slideNodeGroup = display.newGroup()

    -- Create the slide node
    local node = display.newRoundedRect( display.contentCenterX, display.contentCenterY, 200, 100, 8 )

    -- Set some styles for the slide node
    node:setFillColor(constants.color.slideNodeBG)
    node:setStrokeColor(1,1,1)
    node.strokeWidth = 2
    node.id = #slideNodes                -- TODO: Change this to the slide ID
    node.sceneGroup = sceneGroup

    print("slide node id: " ..node.id)

    -- Create an output circle
    local outputCircle = createOutputCirlce(node)

    -- Create an editable text fiel for the slide title
    local title_grp = createTitle(node)

    -- Insert all elements into groups
    slideNodeGroup:insert(node)
    slideNodeGroup:insert(outputCircle)
    
    -- Cache the slide node group in the output circle
    outputCircle.slideNodeGroup = slideNodeGroup

    sceneGroup:insert(slideNodeGroup)
    slideNodeGroup:insert(title_grp)

    -- Add touch listener to slide node
    node:addEventListener( "touch", nodeTouchListener)

    -- cache the slideNodeGroup inside the instance
    instance.slideNodeGroup = slideNodeGroup
    instance.node = node
    node.slideNodeGroup = slideNodeGroup
    node.slideNodeGroup.sceneGroup = sceneGroup

    -- Cache the instance in the slideNodes table
    table.insert(slideNodes, instance)

    return setmetatable(instance, slideNode_mt)
end

-- slideNode:getSlideNodes()
-- Static method to get all the slide nodes
function slideNode.getSlideNodes()
    return slideNodes
end

-- nodeTouchListener()
-- Functionality for selecting and moving a node slide
function nodeTouchListener(event)
if (event.phase == "began") then

    local node = event.target
    local group = event.target.slideNodeGroup

    for n in ipairs(slideNodes) do
       -- print ('node ID' ..node.id)
       -- print('other node ID: ' ..slideNodes[n].node.id)
        if (slideNodes[n].node == node) then
            slideNodes[n].node:setStrokeColor(constants.color.white)
        else
            print (slideNodes[n])
            slideNodes[n].node:setStrokeColor(1,1,1)
        end
    end

    display.getCurrentStage():setFocus( node, event.id )
    node.isFocus = true
    --node.markX = node.x    -- store x location of object
    --node.markY = node.y    -- store y location of object

    group.markX = group.x
    group.markY = group.y

elseif (event.target.isFocus) then

    local node = event.target
    local group = event.target.slideNodeGroup

    if (event.phase == "moved") then

        --local x = (event.x - event.xStart) + node.markX
        --local y = (event.y - event.yStart) + node.markY

        local groupX = (event.x - event.xStart) + group.markX
        local groupY = (event.y - event.yStart) + group.markY

        --node.x = x
        --node.y = y    -- move object based on calculations above
        group.x = groupX
        group.y = groupY

    elseif (event.phase == "ended" or event.phase == "cancelled") then
        display.getCurrentStage():setFocus(node, nil)
        node.isFocus = false
    end
end
return true
end

-- createOutputCircle()
function createOutputCirlce(node)
    local buttonSheet = graphics.newImageSheet('assets/images/outputCircles.png', circleImageSheetOptions)

    local button = widget.newButton({
        sheet = buttonSheet,
        defaultFrame = 1,
        overFrame = 2,
        left = node.x + node.width - 10,
        top = node.y + node.height / 10,
        width = 30,
        height = 30,
        label = "",
        id = 'circle'
    })

    button.slideNodeGroup = node.slideNodeGroup
    button:addEventListener( 'touch', outputCircleHandler )
    return button
end

function outputCircleHandler(event)
    local phase = event.phase
    local target = event.target

    if (phase == 'began') then
        -- Create a curve with a startCap and endCap
        if (not target.curve) then
            event.endCapHandler = endCapHandler

            -- Create some initial coordinates for the control point
            event.cp = { x = event.xStart, y = event.yStart}
            
            target.curve = curve:new(event)
            
            -- Offset the curve group by setting its coordinates to the difference of the curveGroup and the slideNodeGroup
            -- We have to do this because we are offseting the slideNodeGroup if we drag it around
            target.curve.group.x = target.curve.group.x - target.slideNodeGroup.x - target.slideNodeGroup.sceneGroup.x
            target.curve.group.y = target.curve.group.y - target.slideNodeGroup.y - target.slideNodeGroup.sceneGroup.y

            print ('created curve')

            -- cache the outputCirlce in th endCap
            target.curve.group.endCap.outputCircle = target

            -- Insert the curve group into the main scene group
            target.slideNodeGroup:insert(target.curve.group)
        end
    elseif (phase == 'moved') then
        if (target.curve) then
            drawCurve(event, target.curve.group)
        end
    end 

end

-- endCapHandler
function endCapHandler(event)
    local phase = event.phase
    local target = event.target

     if (phase == 'began') then
        
        print ('tapped endCap')
        display.getCurrentStage():setFocus(target)
        target.isFocus = true

        -- Cache the coordinates of the endCap
        target.markX = target.x
        target.markY = target.y

     elseif (event.target.isFocus) then

        if (phase == 'moved') then
            local group = target.outputCircle.curve.group

            -- Offset the endCap by the distance between the world
            -- mouse coordinates and the endCap's local starting coordinates
            target.x = event.x - (event.xStart - target.markX)
            target.y = event.y - (event.yStart - target.markY)

            -- Redraw the curve
            group.line:removeSelf()
            group.line = nil
            
            -- Make sure that the start of the curve is at the startCap
            event.xStart = group.startCap.x
            event.yStart = group.startCap.y

            -- Update the coordinates of the control point
            group.cp.x = group.startCap.x + ((group.endCap.x - group.startCap.x) * 0.5) 
            group.cp.y = group.endCap.y
            event.cp = { x = group.cp.x, y = group.cp.y }
            
            -- Make sure the end of the curve is at the endCap's position
            event.x = target.x
            event.y = target.y
            
            target.outputCircle.curve.group.line = curve:drawLine(event)
            target.outputCircle.curve.group:insert(target.outputCircle.curve.group.line)

         elseif (phase == "ended" or phase == "cancelled") then
            display.getCurrentStage():setFocus(nil)
            target.isFocus = false
        end
     end
    return true
end

function drawCurve(event, group)

    -- Move the endCap to the mouse's coords
    group.endCap.x = event.x
    group.endCap.y = event.y

    group.cp.x = group.startCap.x + ((group.endCap.x - group.startCap.x) * 0.5) 
    group.cp.y = group.endCap.y
    event.cp = { x = group.cp.x, y = group.cp.y }

    -- Redraw the curve
    group.line:removeSelf()
    group.line = nil
    group.line = curve:drawLine(event)
    group:insert(group.line)
end

function createTitle(node)
    local group = display.newGroup()

    local slideTitleOptions = 
    {
        text = "Slide Title",     
        x = node.x + 8,
        y = node.y + 10,
        width = node.width - 25,
        font = native.systemFont,   
        fontSize = 16
    }

    local title = display.newText(slideTitleOptions)
    title:setFillColor(0,0,0)

    local titleTextField = native.newTextField(node.x + 8, node.y + 10, node.width - 25, 20)
    titleTextField.isVisible = false

    -- Toggle title when its double cliked
    local function titleTapHandler(event)
        if (event.numTaps == 2) then
            print('double click')
            event.target.isVisible = false
            titleTextField.isVisible = true
            titleTextField.text = title.text
            native.setKeyboardFocus(titleTextField)
        end
    end
    title:addEventListener('tap', titleTapHandler)

    -- Show title when the user is finished entering text
    local function titleTextFieldHandler(event)
        if (event.phase == 'submitted' or event.phase == 'ended') then
            print ('submitted')
            event.target.isVisible = false
            title.isVisible = true
            title.text = event.target.text
        end
    end
    titleTextField:addEventListener('userInput', titleTextFieldHandler)

    group:insert(title)
    group:insert(titleTextField)
    
    return group
end

return slideNode

