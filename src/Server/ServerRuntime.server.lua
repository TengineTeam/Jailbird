local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)
local Loader = require(ReplicatedStorage.Packages.loader)

Knit.AddServices(script.Parent.Services)

Knit.Start():andThen(function()
    print("knit started")
    --Loader.Start(script.Parent.Components)
end):catch(warn):await()
