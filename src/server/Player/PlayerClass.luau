--!strict
--!native
--!optimize 2

--// Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules

local Packages = ReplicatedStorage.Packages

local Trove = require(Packages.Trove)
local Lapis = require(Packages.Lapis)
local t = require(Packages.t)

--// Table

local PlayerClass = {}
PlayerClass.__index = PlayerClass

export type Data = {}

local DefaultData = {} :: Data

PlayerClass.DefaultDataType = {}

local DataCollection

if game.PlaceId ~= 0 then
	DataCollection = Lapis.createCollection(
		"Data",
		{ defaultData = DefaultData, validate = t.strictInterface(PlayerClass.DefaultDataType) }
	)
end

export type PlayerClassType = typeof(setmetatable(
	{} :: {
		_Trove: Trove.Trove,
		Player: Player,
		Data: Data,
		Document: any,

		Destroy: (self: PlayerClassType) -> (),
	},
	PlayerClass
))

function PlayerClass.new(Player: Player): PlayerClassType
	local self = {}

	self.Player = Player
	self.Data = DefaultData
	self.Document = nil :: any
	self._Trove = Trove.new()

	if game.PlaceId ~= 0 then
		DataCollection:load(`Player{self.Player.Name}`, { self.Player.UserId })
			:andThen(function(Document)
				if not self.Player.Parent then
					Document:close():catch(warn)
					return
				end

				self.Document = Document
			end)
			:catch(function(Message)
				self.Player:Kick("Hey there! Unfortunately your data failed to load! No data has been lost")
				self._Trove:Destroy()
				warn(Message)
			end)
	end

	return setmetatable(self, PlayerClass) :: PlayerClassType
end

function PlayerClass.Destroy(self: PlayerClassType)
	if self.Document then
		local Document = self.Document :: any

		Document:close():catch(warn)
	end

	self._Trove:Destroy()
end

return PlayerClass
