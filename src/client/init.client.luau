--!strict
--!optimize 2

local Players = game:GetService("Players")

local ModuleSuffix = "Handler"

local Handlers = {}

for _, Descendant in script:GetDescendants() do
	if not Descendant:IsA("ModuleScript") then
		continue
	end

	if not string.match(Descendant.Name, ModuleSuffix, Descendant.Name:len() - ModuleSuffix:len()) then
		continue
	end

	task.spawn(function()
		local RequiredDescendant = require(Descendant) :: any
		Handlers[Descendant.Name] = RequiredDescendant

		RequiredDescendant.Player = Players.LocalPlayer

		debug.setmemorycategory(Descendant.Name)
	end)
end
