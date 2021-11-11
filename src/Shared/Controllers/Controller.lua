local RunService = game:GetService("RunService")
local updateRemoteFunction
local updateRemoteEvent

local controllerMap = {}

if RunService:IsServer() then
	updateRemoteFunction = Instance.new("RemoteFunction", game.ReplicatedStorage)
	updateRemoteEvent = Instance.new("RemoteEvent", game.ReplicatedStorage)

    updateRemoteFunction.OnServerInvoke = function(player, controllerName, controllerMethodName, ...)
        local controller = controllerMap[controllerName]
        if not controller then error("Controller with name '" .. controllerName .. "' does not exist") end
        local method = controller[controllerMethodName]
        if not method then error(controllerName .. " has no method '" .. controllerMethodName .. "'.") end
        return method(...)
	end
else
	updateRemoteFunction = game.ReplicatedStorage:FindFirstChild("RemoteFunction")
	updateRemoteEvent = game.ReplicatedStorage:FindFirstChild("RemoteEvent")
end

return function(Controller, controllerName)
    controllerMap[controllerName] = Controller
    local updateEvents = {}
    function Controller.OnUpdate(fn)
        table.insert(updateEvents, fn)
    end

    function Controller.Update()
        for _, event in ipairs(updateEvents) do
            event()
        end
        if RunService:IsServer() then
            updateRemoteEvent:FireAllClients(controllerName)
        end
    end

    if RunService:IsClient() then
        updateRemoteEvent.OnClientEvent:Connect(function()
            Controller.Update()
        end)
        
        return setmetatable({}, {__index = function(t, index)
            local member = rawget(Controller, index)
            -- Quick workaround for checking Update and OnUpdate
            if typeof(member) == "function" and index ~= "Update" and index ~= "OnUpdate" then
                return function (...)
                    return updateRemoteFunction:InvokeServer(controllerName, index, ...)
                end
            end
            return member
        end})
    end
end