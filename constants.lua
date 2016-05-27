local color = {

    black = unpack({0,0,0}),

    white = unpack({1,1,1}),

    transparent = unpack({1,1,1,0}),

    slideNodeBG = unpack({224/255, 224/255, 224/255}),

    grey = unpack({204/255, 204/255, 204/255})
}

-- Settings for the slide node connection curves
local curveSettings = {
	showCP = false,			-- For toggling the display of curve control points
	curveWidth = 1 			-- default stroke width of all curves
}

local constants = {
    color = color,
    curveSettings = curveSettings
}

return constants




