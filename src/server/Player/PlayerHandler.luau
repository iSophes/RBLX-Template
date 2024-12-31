--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Sift = require(Packages.Sift)
local Warp = require(Packages.Warp)

local PlayerClass = require(script.Parent.PlayerClass)

local PlayerHandler = {}
PlayerHandler.Players = {} :: { [Player]: PlayerClass.PlayerClassType }

local GetData = Warp.Server("GetPlayerData")

type Handler = typeof(PlayerHandler)

function PlayerHandler.onPlayerAdded(self: Handler, Player: Player)
	local NewPlayerObject = PlayerClass.new(Player)
	self.Players[Player] = NewPlayerObject
end

PlayerHandler.onPlayerRemoving = function(self: Handler, Player: Player)
	self.Players[Player]:Destroy()
	self.Players[Player] = nil
end

PlayerHandler.GetPlayerData = function(self: Handler, Player: Player)
	repeat
		wait()
	until self.Players[Player]

	if game.PlaceId == 0 then
		return self.Players[Player].Data
	end

	return self.Players[Player].Document:read() :: PlayerClass.Data
end

PlayerHandler.SetPlayerData = function(self: typeof(PlayerHandler), Player: Player, NewData: {})
	if not self.Players[Player].Document then
		return
	end

	local Data = self:GetPlayerData(Player)
	local NewDictionary = Sift.Dictionary.merge(Data, NewData)

	self.Players[Player].Document:write(NewDictionary)
	return NewDictionary
end

GetData:Connect(function(Player: Player)
	return PlayerHandler:GetPlayerData(Player) :: PlayerClass.Data
end)

return PlayerHandler
