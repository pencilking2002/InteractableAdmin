-- base size is 1200 X 800
local aspectRatio = display.pixelHeight / display.pixelWidth
application = {
	content = 
        {
            --width = aspectRatio > 1.5 and 800 or math.floor(1200/aspectRatio),
            --height = aspectRatio > 1.5 and 1200 or math.floor(800 * aspectRatio),
            --width = aspectRatio > 1.5 and 768 or math.floor(1024/aspectRatio),
            --height = aspectRatio > 1.5 and 1024 or math.floor(768 * aspectRatio),
            --width = 1024,
            --height = 720,
            scale = "letterBox",
            fps = 60,
            
            -- HD Images prefixes
            imageSuffix = 
            {
                ["@2x"] = 1.3,
            }

        },

    --[[
    -- Push notifications

    notification =
    {
        iphone =
        {
            types =
            {
                "badge", "sound", "alert", "newsstand"
            }
        }
    }
    --]]    
}
