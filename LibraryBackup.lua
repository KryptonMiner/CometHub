--[[
  ______   ____    ____  _______ .______       __  ___  __   __       __      
 /  __  \  \   \  /   / |   ____||   _  \     |  |/  / /_ | |  |     |  |     
|  |  |  |  \   \/   /  |  |__   |  |_)  |    |  '  /   | | |  |     |  |     
|  |  |  |   \      /   |   __|  |      /     |    <    | | |  |     |  |     
|  `--'  |    \    /    |  |____ |  |\  \----.|  .  \   | | |  `----.|  `----.
 \______/      \__/     |_______|| _| `._____||__|\__\  |_| |_______||_______|


Documentation

Get the functions

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/typical-overk1ll/scripts/main/ConsoleLib",true))()

Create UI/Rename it

lib:add("Your name here")

Send A Message

lib:message("Your message here")

Send An Information Marked Message

lib:infoMessage("Your message here")

Send A Warning Marked Message

lib:warnMessage("Your message here")

Send An Error Marked Message

lib:errorMessage("Your message here")

Add a space in between messages

lib:makeSpace()

Set the color of the next printed messages

lib:setColor("White")   note: replace White with any of the following colors (case sensitive):
Black
Blue
Green
Cyan
Red
Magenta
Brown
Light Gray
Dark Gray
Light Blue
Light Green
Light Cyan
Light Red
Light Magenta
Yellow
White


Add an Input Function

lib:addInput("Trigger Message",function()
 Your code here
end)




























































































]]
local lib = {}
local RunService = game:GetService("RunService")


function lib:add(name)
    rconsolename(name)
end

function lib:message(msg)
    rconsoleprint(msg.."\n")
end


function lib:addInput(trigger,callback)
    RunService.RenderStepped:Connect(function()
        local input = rconsoleinput(input)
        if trigger == input then
            callback()
        end
    end)
end

return lib
