local scriptloadstring = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/laagginq/public-script-hub/main/main.lua"))() ]]
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local scripts = game:GetService("HttpService"):JSONDecode(httprequest(
    {Url = 'https://raw.githubusercontent.com/laagginq/public-script-hub/main/scripts.json'
}).Body)['Scripts']

local games = game:GetService("HttpService"):JSONDecode(httprequest(
    {Url = 'https://raw.githubusercontent.com/laagginq/public-script-hub/main/games.json'
}).Body)['Games']

local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/laagginq/public-script-hub/main/ui.lua'))()

local Window = library:CreateWindow("Script Hub", "xz#1111", 10044538000)

local antiafkon = false
local function AntiAFK() 
   if antiafkon == false then 
      antiafkon = true
      local GC = getconnections or get_signal_cons
      if GC then
         for i,v in pairs(GC(game.Players.LocalPlayer.Idled)) do
            if v["Disable"] then
               v["Disable"](v)
            elseif v["Disconnect"] then
               v["Disconnect"](v)
            end
         end
      else
         game.Players.LocalPlayer.Idled:Connect(function()
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
         end)
      end
      CreateNotification("Loaded", "Anti AFK")
   end
end

local function Request_Teleport(scriptname,creator,placeid)
    CreateNotification("Teleport Request", "Are you sure you want to join "..scriptname.." by "..creator, function(value)
        if value == true then
            queue_on_teleport(scriptloadstring)
            local success , err = pcall(function()
                game:GetService("TeleportService"):Teleport(placeid, game.Players.LocalPlayer)
             end)
             if success then 
                CreateNotification("Successfully Teleporting", v.Name)
             else
                CreateNotification("Error Loading "..v.Name, err)
             end
        end
    end)
end

local Tab = Window:CreateTab("Scripts")

local Scripts1 = Tab:CreateFrame("Scripts #1")

CreateNotification("Loading...", "Please wait for script to fully load.")

for i,v in ipairs(scripts) do 
   Scripts1:CreateButton(v.Name, v.Description, function()
      local success , err = pcall(function()
         loadstring(game:HttpGet(v.Url))()
      end)
      if success then 
         CreateNotification("Successfully Loaded", v.Name)
      else
         CreateNotification("Error Loading "..v.Name, err)
      end
   end)
   game:GetService("RunService").Heartbeat:Wait()
end

local gamestab = Tab:CreateFrame("Games")

for i,v in ipairs(games) do 
   gamestab:CreateButton(v.Name, "Made By: "..v.Creator, function()
        Request_Teleport(v.Name,v.Creator,v.PlaceId)
   end)
   game:GetService("RunService").Heartbeat:Wait()
end

local extra = Tab:CreateFrame("Extra")
extra:CreateLabel("Made by xz#1111")

extra:CreateButton("Anti AFK", "Will prevent you from being kicked for being idle.", function()
    AntiAFK()
end)


extra:CreateButton("Server Hop", "Will make you join a random server.", function()
    queue_on_teleport(scriptloadstring)
    local Player = game.Players.LocalPlayer    
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/"

    local _place,_id = game.PlaceId, game.JobId
    local _servers = Api.._place.."/servers/Public?sortOrder=Desc&limit=100"
    function ListServers(cursor)
       local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
       return Http:JSONDecode(Raw)
    end

    local Next; repeat
       local Servers = ListServers(Next)
       for i,v in next, Servers.data do
          if v.playing < v.maxPlayers and v.id ~= _id then
            CreateNotification("Server Hop", "Joining: "..tostring(v.id))
             wait(0.5)
             local s,r = pcall(TPS.TeleportToPlaceInstance,TPS,_place,v.id,Player)
             if s then break end
          end
       end
       
       Next = Servers.nextPageCursor
    until not Next
end)

extra:CreateButton("Join Lowest Pop","Will make you join the lowest population server",function()
    queue_on_teleport(scriptloadstring)
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/"
    
    local _place = game.PlaceId
    local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
    function ListServers(cursor)
       local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
       return Http:JSONDecode(Raw)
    end
    
    local Server, Next; repeat
       local Servers = ListServers(Next)
       Server = Servers.data[1]
       Next = Servers.nextPageCursor
    until Server
    CreateNotification("Server Hop", "Joining: "..tostring(Server.id))
    wait(0.5)
    TPS:TeleportToPlaceInstance(_place,Server.id,game.Players.LocalPlayer)
end)

CreateNotification("Loaded", "Thank you for using <3")
