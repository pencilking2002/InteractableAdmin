--[[---------------------------------------------------------------------------\
|   @class curve                                                        	   |
|   romansharf - 5/2/16/05/2016                                                |
-------------------------------------------------------------------------------|            
|                                                                              |
\-----------------------------------------------------------------------------]]
local utils = require('scripts.lib.utils')
local bezier = require('scripts.lib.bezier')
local constants = require('constants')

local curve = {}
curve.curves = {}			-- All the existing curves in the scene

local createCaps
local createLine

function curve:new(event)
	local instance = {}

	-- Create a new display group for the curve
	local group = display.newGroup()

	-- Create start and end caps for the curve
	local startCap, cp, endCap = createCaps(event)

	-- Create a line to use for the curve
	local line = createLine(event)

	-- Insert all the curve elements into the curve group
	group:insert(startCap)
	group:insert(cp)
	group:insert(endCap)
	group:insert(line)

	-- Cache references to the curve elements in the curve group
	group.startCap = startCap
	group.cp = cp
	group.endCap = endCap
	group.line = line

	-- Hide or show the control points
	cp.isVisible = constants.curveSettings.showCP
	
	-- Cache the curve group in the curve instance
	instance.group = group

	return setmetatable(instance, {__index = curve})
end

function createCaps(event)

	-- Create startCap, endCap, and control point
	local startCap = display.newCircle(event.x, event.y, 15)
	local cp = display.newCircle(event.x, event.y, 15)
	local endCap = display.newCircle(event.x, event.y, 15)

	-- Color the caps
	startCap:setFillColor(18/255, 187/255, 252/255)
	endCap:setFillColor(255/255, 106/255, 90/255)

	-- Assign IDs to the caps
	startCap.id = 'startCap'
	endCap.id = 'endCap'
	
	-- Apply some styles to the control point
	cp:setFillColor(0)
	cp:setStrokeColor(1,1,1)
	cp.strokeWidth = constants.curveSettings.curveWidth

	-- Adjust the anchor points of the curve's elements
	utils.setAnchors(startCap, 0.5, 0.5)
	utils.setAnchors(cp, 0.5, 0.5)
	utils.setAnchors(endCap, 0.5, 0.5)

	-- If provided, attach a touch listener for the endCap
	if (event.endCapHandler ~= nil) then
		endCap:addEventListener('touch', event.endCapHandler)
	end
	
	return startCap, cp, endCap
end

function createLine (event)

	-- the points for the curve's starting/ending coords
	-- as well as the control point
	local points = 
		bezier:curve(
			{event.xStart, event.cp.x, event.x}, 
			{event.yStart, event.cp.y, event.y})

	local x1, y1 = points(0.01)
	local line = display.newLine(event.xStart, event.yStart, event.xStart, event.yStart)
	line:setStrokeColor(1,1,1)
	line.strokeWidth = constants.curveSettings.curveWidth

	for i=0.02, 1, 0.01 do
		local x, y = points(i)
		line:append(x, y)
	end

	return line
end

function curve:drawLine(event)
	return createLine(event)
end
return curve