--!strict
--!native
--!optimize 2

-- character
-- simple utility module for getting accurate character types,
-- and with a special added function that also runs the callback
-- if the player already has a character

export type Character = Model & {
	Humanoid: Humanoid & {
		HumanoidDescription: HumanoidDescription,
		Animator: Animator,
	},
	HumanoidRootPart: BasePart,
	BodyColors: BodyColors,
	PrimaryPart: BasePart,
	Animate: LocalScript,
	Head: BasePart,
}

-- maps players w their characters appearance loaded to their character
local CHARACTER_APPEARANCE_LOADED = {} :: { [Player]: Character? }

local function GET_APPEARANCE_LOADED(player: Player): Character?
	return CHARACTER_APPEARANCE_LOADED[player]
end

-- this function exists so u dont have to do
-- local character = (player.Character :: any) :: character.Character?
local function GET(player: Player): Character?
	return player.Character :: any
end

local character = {}

function character.removing_once(player: Player, f: (character: Character) -> ()): () -> ()
	local removing_conn = player.CharacterRemoving:Once(f :: any)

	return function()
		if removing_conn.Connected then
			removing_conn:Disconnect()
		end
	end
end

function character.removing(player: Player, f: (character: Character) -> ()): () -> ()
	local removing_conn = player.CharacterRemoving:Connect(f :: any)

	return function()
		removing_conn:Disconnect()
	end
end

function character.added(
	player: Player,
	f: (character: Character) -> (),
	dont_run_for_existing_character: boolean?
): () -> ()
	local Character = GET(player)
	local removing_conn: RBXScriptConnection?
	local thread: thread

	if Character and not dont_run_for_existing_character then
		thread = task.defer(f, Character)

		removing_conn = player.CharacterRemoving:Once(function()
			coroutine.close(thread)
		end)
	end

	local added_conn = player.CharacterAdded:Connect(f :: any)

	return function()
		if removing_conn and removing_conn.Connected then
			removing_conn:Disconnect()
		end

		if added_conn then
			added_conn:Disconnect()
		end

		coroutine.close(thread)
	end
end

function character.added_once(
	player: Player,
	f: (character: Character) -> (),
	dont_run_for_existing_character: boolean?
): () -> ()
	local Character = GET(player)

	if Character and not dont_run_for_existing_character then
		local thread = task.defer(f, Character)

		local conn = player.CharacterRemoving:Once(function()
			coroutine.close(thread)
		end)

		return function()
			if conn.Connected then
				conn:Disconnect()
			end
			coroutine.close(thread)
		end
	else
		local conn = player.CharacterAdded:Once(f :: any)

		return function()
			if conn.Connected then
				conn:Disconnect()
			end
		end
	end
end

function character.appearance_loaded(
	player: Player,
	f: (character: Character) -> (),
	dont_run_for_existing_character: boolean?
): () -> ()
	local Character = GET_APPEARANCE_LOADED(player)
	local removing_conn: RBXScriptConnection?
	local thread: thread

	if Character and not dont_run_for_existing_character then
		thread = task.defer(f, Character)

		removing_conn = player.CharacterRemoving:Once(function()
			coroutine.close(thread)
		end)
	end

	local added_conn = player.CharacterAppearanceLoaded:Connect(f :: any)

	return function()
		if removing_conn and removing_conn.Connected then
			removing_conn:Disconnect()
		end

		if added_conn then
			added_conn:Disconnect()
		end

		coroutine.close(thread)
	end
end

function character.appearance_loaded_once(
	player: Player,
	f: (character: Character) -> (),
	dont_run_for_existing_character: boolean?
): () -> ()
	local Character = GET_APPEARANCE_LOADED(player)

	if Character and not dont_run_for_existing_character then
		local thread = task.defer(f, Character)

		local conn = player.CharacterRemoving:Once(function()
			coroutine.close(thread)
		end)

		return function()
			if conn.Connected then
				conn:Disconnect()
			end
			coroutine.close(thread)
		end
	else
		local conn = player.CharacterAppearanceLoaded:Once(f :: any)

		return function()
			if conn.Connected then
				conn:Disconnect()
			end
		end
	end
end

character.get_appearance_loaded = GET_APPEARANCE_LOADED
character.get = GET

character.PlayerAdded = function(_, Player: Player)
	Player.CharacterAppearanceLoaded:Connect(function(Character: any)
		CHARACTER_APPEARANCE_LOADED[Player] = Character
	end)

	Player.CharacterRemoving:Connect(function()
		CHARACTER_APPEARANCE_LOADED[Player] = nil
	end)
end

character.PlayerRemoving = function(_, Player: Player)
	CHARACTER_APPEARANCE_LOADED[Player] = nil
end

return table.freeze(character)
