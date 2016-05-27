--[[---------------------------------------------------------------------------\
|   @class dropDownMenu                                                        |
|   romansharf - 5/2/16/05/2016                                                |
-------------------------------------------------------------------------------|            
|                                                                              |
\-----------------------------------------------------------------------------]]
local DDM = require ('scripts.lib.DropDownMenu')
local RowData = require ('scripts.lib.RowData')
local database = require('scripts.database')
local db = database:getInstance()

-- Variable forward declarations
local scenarioMenu = {}
local dropDownMenu_mt = { __index = scenarioMenu }

-- Method forward declarations
local createDropDownMenu
local onRowSelected

function scenarioMenu.new(x, y)
    local instance = {}
    instance.menu = createDropDownMenu(x,y)
    return setmetatable(instance, dropDownMenu_mt)
end

-- createDropDownMenu()
function createDropDownMenu(x,y)
    -- Get all scenarios from the db
    local scenarios = db:getScenarios()

    -- Object we will use to polulate the dropdown menu
    local scenarioData = {}

    for i in ipairs(scenarios) do
        local title = scenarios[i].title
        local id = scenarios[i].id
        local rowData = RowData.new(id .. ' ' ..title, {ID = id})
        scenarioData[i] = rowData
    end

    -- Initializing the DropDownMenu object
    local colorDDM = DDM.new({
        name = "colors",
        x = x,
        y = y,
        width = 200,
        height = 40,
        dataList = scenarioData,
        onRowSelected = onRowSelected,
        visibleCellCount = #scenarios,
        fontSize = 14
        --rowColor = {0,0,0},
        --lineColor = {0,0,0}
    })

    return colorDDM

end

-- Callback function that is called when a row is clicked.
function onRowSelected(name, rowData)
    if name == "colors" then
        print("Selected scenario is " .. rowData.value)
    end
end

return scenarioMenu


-- DropDownMenu module

-- Color DDM Row Data
