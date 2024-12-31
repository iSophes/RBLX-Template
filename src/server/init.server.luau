--!native
--!strict

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

		debug.setmemorycategory(Descendant.Name)
	end)
end

for _, Player in Players:GetChildren() do
	for _, Handler in Handlers do
		if not Handler.PlayerAdded then
			continue
		end

		task.spawn(function()
			Handler:PlayerAdded(Player)
		end)
	end
end

Players.PlayerAdded:Connect(function(Player: Player)
	for _, Handler in Handlers do
		if not Handler.onPlayerAdded then
			continue
		end

		task.spawn(function()
			Handler:onPlayerAdded(Player)
		end)
	end
end)

Players.PlayerRemoving:Connect(function(Player: Player)
	for _, Handler in Handlers do
		if not Handler.onPlayerRemoving then
			continue
		end

		task.spawn(function()
			Handler:onPlayerRemoving(Player)
		end)
	end
end)

game:BindToClose(function()
	for _, Handler in Handlers do
		if not Handler.onClose then
			continue
		end

		Handler:onClose()
	end
end)
