--[[---------------------------------------------------------------------------\
|   @class Database                                                            |
|   romansharf - 5/2/16/05/2016                                                |
-------------------------------------------------------------------------------|            
| Methods for reading and updating the database                                |                                             |
\-----------------------------------------------------------------------------]]


local sqlite3 = require('sqlite3')


-- The database that holds the game content
local contentDB_Name = 'development-db.sqlite3'
local contentDB_Path = system.pathForFile(contentDB_Name, system.ResourceDirectory)
local _contentDatabase = sqlite3.open(contentDB_Path);

-- The database that holds the data for the admin
local adminDB_Name = 'admin-db.sqlite3'
local adminDB_Path = system.pathForFile(adminDB_Name, system.DocumentsDirectory);
local _adminDatabase = sqlite3.open(adminDB_Path)

-- vars for class functionality
local Database = {}
local Database_mt = { __index = Database }

function Database.new()
    local instance = {}

    return setmetatable(instance, Database_mt)
end


-- TODO look more into this
local function createSaveFile()
    --print("I'm in create save file")
    -- Set up the tables if they don't exist
    local tablesetup1 = [[CREATE TABLE IF NOT EXISTS steps(id integer PRIMARY KEY NOT NULL, play_through_id integer, type integer, clickable_id integer, clickable_type text, slide_id integer, created_at text NOT NULL, updated_at text NOT NULL, achievement_id integer, scenario_id integer);]]

    local tablesetup2 = [[CREATE TABLE IF NOT EXISTS play_throughs(
        id integer PRIMARY KEY NOT NULL, scenario_id integer, child_id integer,
        current integer DEFAULT 0, created_at text NOT NULL, updated_at text NOT NULL);]]

    return (_contentDatabase:exec( tablesetup1 ) == sqlite3.OK) and
            (_adminDatabase:exec( tablesetup2 ) == sqlite3.OK)
end

local function init()
    --print("database init() called")
    if (_contentDatabase == nil) then
        print("Database connection was not established");
    else
        local database; --forward declaration of instance

        if (createSaveFile()) then
            database = {
                readable = _contentDatabase,
                writeable = _adminDatabase,
                --allScenarioMemory = _allScenarioMemory
            }
            print("Save file created succesfully")
        else
            error("database went wrong during init")
        end
        return setmetatable(database, Database_mt)
    end
end

init()

function Database:getInstance()
    return self
end

local function executeSelectContent(query)
    local result = {};
    --local query = _query;
    --print(_query);
    for row in _contentDatabase:nrows(query) do
        table.insert(result, row); --avoid table.insert if possible
    end

    return result;

end

local function executeSelectAdmin(query)
    local result = {};
    for row in _adminDatabase:nrows(query) do
        table.insert(result, row); --avoid table.insert if possible
    end

    return result;
end


-- TODO: Create method to get the all the slides in a specified scenario
function Database:getSlidesInScenario(scenarioID)

    local query = "SELECT slide_id FROM slides WHERE scenario_id=".. scenarioID .. "  ORDER BY id DESC LIMIT 3"
    local results = executeSelectContent(query)

    if (results ~= nil) then
        return results
    else
        print ('Database:getSlidesInScenario() failed to to results')
        return false
    end
end

function Database:getScenarios(ScenarioIDFilter)
--    if (ScenarioIDFilter ~= nil) then
--        local query = "SELECT * FROM scenarios WHERE id=" .. ;
--    end

    local query = "SELECT * FROM scenarios";
    local results = executeSelectContent(query)

    if (results ~= nil) then
        --print('results not nil')
        return results
    else
        print ('Database:getScenarios() failed to to results')
    end

end


--function Database
return Database