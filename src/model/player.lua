class("Player").extends()

function Player:init(player)
	self.id = player.id
	self.hidden = player.hidden or false
	self.name = player.name
	self.created = player.created
	self.played = player.played
	self.options = player.options or {}

	local avatar = playdate.datastore.readImage(AVATAR_FOLDER_NAME .. self.id)
	if avatar then
		self.avatar = avatar
	else
		local id =
			(self.id == PLAYER_ID_RDK and AVATAR_ID_RDK) or
			(self.id == PLAYER_ID_QUICK_PLAY and AVATAR_ID_QUICK_PLAY) or
			AVATAR_ID_NIL
		self.avatar = imgAvatars:getImage(id)
	end
end

function Player:save(context)
	local player = {
		id = self.id,
		hidden = self.hidden,
		name = self.name,
		created = self.created,
		played = self.played,
		options = self.options
	}

	context.save.profiles[self.id] = player

	local hasProfile = false
	for _, id in pairs(context.save.profileList) do
		if id == player.id then
			hasProfile = true
		end
	end

	if not hasProfile then
		table.insert(context.save.profileList, self.id)
	end

	playdate.datastore.writeImage(self.avatar, AVATAR_FOLDER_NAME .. self.id)
	playdate.datastore.write(context.save)
end

function Player:delete(context)
	-- hide profile if player has created puzzles
	if #self.created > 0 then
		self.hidden = true
		self:save(context)
	else
		local playerIndex = nil
		for i, id in pairs(context.save.profileList) do
			if id == self.id then
				playerIndex = i
			end
		end

		if playerIndex then
			table.remove(context.save.profileList, playerIndex)
		end
		context.save.profiles[self.id] = nil

		playdate.datastore.write(context.save)
	end
end

function Player:getNumPlayed()
	local numPlayed = 0
	for _ in pairs(self.played) do
		numPlayed += 1
	end
	return numPlayed
end

function Player:playedAllBy(creator)
	if self.id == creator.id then
		return true
	end
	for _, id in pairs(creator.created) do
		if not self.played[id] then
			return false
		end
	end
	return true
end

Player.load = function (context, id)
	return Player(context.save.profiles[id])
end

function Player.createEmpty()
	return Player({
		id = playdate.string.UUID(16),
		hidden = false,
		avatar = AVATAR_ID_NIL,
		name = "",
		created = {},
		played = {}
	})
end
