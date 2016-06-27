--[[---------------------------------------------------------------------------\
|   @class menuBar                                                             |
|   romansharf - 5/10/16/05/2016                                               |
-------------------------------------------------------------------------------|            
| The menu bar                                                                 |
\-----------------------------------------------------------------------------]]

local database = require('scripts.database')
local db = database:getInstance()

local constants = require('constants')
local widget = require('widget')


--[[-------------------------------------------\
| Forward variable delcarations                |
\---------------------------------------------]]

local menuBarClass = {}
local menuBar_mt = { __index = menuBarClass }
local scenarios
local instance = nil
local menuBar_grp
local menuItems_grp
local subMenuGroups = {}
local menuItems = {
    go = {},

    file =
    {
        'save',
        'open',
        'import',
        'export'
    },
}
local openMenu = nil                -- the menu that is currently open

local draggableMenuProps = {
    startingY = 0,
    min = 50,
    max = 50
}

local pushFront = {}
local mouseYPos                     -- the current mouse position, used in dragging an open menu up and down
--[[-------------------------------------------\
| Forward method delcarations                  |
\---------------------------------------------]]

local createBackground
local createMenuItems
local createSubMenu
local verticalMenuDragHandler
local closeOpenMenuHandler
local isDraggingUp
local isDraggingDown
local menuCanDragUp
local menuCanDragDown

--[[-------------------------------------------\
| Public methods                               |
\---------------------------------------------]]

-- menuBar.init()
-- Singleton Constructor for the menu bar
function menuBarClass.init(sceneGroup)
    if (instance == nil) then

        instance = {}
        instance.sceneGroup = sceneGroup

        -- Get All scenarios from the database
        scenarios = db:getScenarios()

        for i in ipairs(scenarios) do
            local title = scenarios[i].title
            local id = scenarios[i].id
            table.insert(menuItems.go, title)

            --local rowData = RowData.new(id .. ' ' ..title, {ID = id})
            --scenarioData[i] = rowData
        end

        menuBar_grp = createBackground()
        menuItems_grp = createMenuItems()
        instance.sceneGroup:insert(menuBar_grp)

        menuBar_grp:insert(menuItems_grp)

        -- Give menu ability to hide when user clicks off
        closeOpenMenuHandler()

    end

    return setmetatable(instance, menuBar_mt)
end

--[[-------------------------------------------\
| Private methods                              |
\---------------------------------------------]]

-- createBackground()
-- Create the backgroud for the menu and make it resize to
-- the window's width
function createBackground ()
    menuBar_grp = display.newGroup()

    local bg = display.newRect(0,0, display.contentWidth, 30)
    bg:setFillColor(constants.color.grey)

    -- Resize the menu background when the window resizes
    Runtime:addEventListener('resize', function(e)
        bg.width = display.contentWidth
    end)

    menuBar_grp:insert(bg)
    return menuBar_grp
end

-- createMenuItems()
function createMenuItems()

    local menuItems_grp = display.newGroup()
    local menuPosX = 10
    local buttonWidth = 40
    local buttonHeight = 44
    local buttonPadding = 50

    for k,v in pairs(menuItems) do
        local menuItem = widget.newButton({
          x = menuPosX,
          y = -13,
          label = k,
          labelColor = { default={0, 0, 0}, over={1, 1, 1} },
          width = buttonWidth,
          height = buttonHeight,
        })

        local subMenu_grp = createSubMenu(v, menuItem)
        subMenu_grp.isVisible = false
        menuItem.subMenu_grp = subMenu_grp

        -- Toggle menu visibility
        menuItem:addEventListener('touch', function(e)
            if (e.phase == 'began') then
                menuItem.subMenu_grp.isVisible = (not menuItem.subMenu_grp.isVisible)

                if (menuItem.subMenu_grp.isVisible) then

                    -- Insert sub menu into the open menu variable
                    -- That way we can close it easily later
                    openMenu = menuItem.subMenu_grp
                    menuItem.subMenu_grp.y = 0
                end

                for i in ipairs(subMenuGroups) do
                    if (menuItem.subMenu_grp ~= subMenuGroups[i]) then
                        subMenuGroups[i].isVisible = false
                    end
                end
            end
        end)

        menuPosX = menuPosX + buttonPadding
        menuItems_grp:insert(menuItem)
        instance.sceneGroup:insert(subMenu_grp)

    end

    return menuItems_grp
end

-- createSubMenu()
function createSubMenu(subMenuItems, menuItem)
    local subMenu_grp = display.newGroup()
    table.insert(subMenuGroups, subMenu_grp)

    local subMenuPosY = 30
    local subMenuPaddingX = 10
    local subMenuWidth = 20
    local subMenuHeight = 40
    local subMenuPadding = 40

    local rect = display.newRect(menuItem.x, menuItem.y + menuItem.height, 120, 200)
    local bgWidth = 0

    rect:setFillColor(constants.color.grey)
    rect:setStrokeColor(constants.color.black)
    rect.strokeWidth = 1
    subMenu_grp:insert(rect)

    for k,v in ipairs(subMenuItems) do

        -- if we are in the 'go' menu, record its y position
        if (k == 'go') then
            draggableMenuProps.startingY = subMenu_grp.y
        end

        local subMenuItem = widget.newButton({
            x = menuItem.x + subMenuPaddingX,
            y = subMenuPosY,
            label = v,
            labelColor = { default={0, 0, 0}, over={1, 1, 1} },
            width = subMenuWidth,
            height = subMenuHeight,
        })
        -- Get the widest menu item name
        if (subMenuItem.width > bgWidth) then
            bgWidth = subMenuItem.width
        end

        subMenu_grp:insert(subMenuItem)
        subMenuPosY = subMenuPosY + subMenuPadding
    end

    rect.height = #subMenuItems * (subMenuHeight)
    rect.width = bgWidth + 20
    subMenu_grp.rect = rect

    if (rect.height > display.contentHeight) then
        subMenu_grp:addEventListener('touch', verticalMenuDragHandler)
    end


    return subMenu_grp
end

-- verticalMenuDragHandler()
-- Allows user to drag the menu up and down when
-- the menu vertical size is larger than the window
function verticalMenuDragHandler (event)
--    local min = 100
--    local max = 100

    if (event.phase == 'began') then

        display.getCurrentStage():setFocus( menu, event.id )
        local menu = event.target
        menu.isFocus = true
        menu.markY = menu.y    -- store y location of object

        -- Record the mouse position when the mouse click began
        mouseYPos = event.y

    elseif (event.target.isFocus) then
        local menu = event.target

        if (event.phase == "moved") then

            --print ('mouse pos began: ' ..mouseYPos)
            --print ('current mouse pos: ' .. event.y)

            local y = (event.y - event.yStart) + menu.markY
            if (
                 (isDraggingDown(event) and menuCanDragDown(menu)) or
                 (isDraggingUp(event) and menuCanDragUp(menu))
               ) then
                menu.y = y

                -- Make sure the menu's Y never goes above 0
                -- which means that its top sticks to the bottom of the menu bar
                if (menu.y > 0) then
                    menu.y = 0
                end
            end

        elseif (event.phase == "ended" or event.phase == "cancelled") then

            display.getCurrentStage():setFocus(menu, nil)
            menu.isFocus = false
        end
    end
    return true
end

-- closeOpenMenuHandler()
-- Handler to close any open menus when the user clicks off the menu
function closeOpenMenuHandler()
    Runtime:addEventListener('touch', function(e)
        if (e.phase == 'ended') then
            if (openMenu ~= nil) then
                openMenu.isVisible = false
            end
        end
    end)
end

-- isDraggingDown()
-- Used to tell whether the user is dragging down
function isDraggingDown(event)
    return mouseYPos < event.y
end

-- isDraggingUp
-- Used to tell if the user is dragging up
function isDraggingUp(event)
    return mouseYPos > event.y
end

-- menuCanDragUp()
-- Used to tell whether the menu can be dragged up
-- So that it doesn't end up above the menu bar
function menuCanDragUp(menu)
    return menu.y > -display.contentHeight
end

-- menuCanDragUp()
-- Used to tell whether the menu can be dragged down
-- So that its top doesn't go below the menu bar
function menuCanDragDown(menu)
    return menu.y <= 0
end

return menuBarClass