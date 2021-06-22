class("Player").extends()

function Player:init(player)
	self.id = player.id
	self.hidden = player.hidden
	self.name = player.name
	self.created = player.created
	self.played = player.played

	local avatar = playdate.datastore.readImage(AVATAR_FOLDER_NAME .. self.id)
	if avatar then
		self.avatar = avatar
	else
		self.avatar = imgAvatars:getImage(AVATAR_ID_NIL)
	end
end

function Player:save(context)
	local player = {
		id = self.id,
		name = self.name,
		created = self.created,
		played = self.played
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

function Player.createEmpty()
	return Player({
		id = playdate.string.UUID(16),
		avatar = AVATAR_ID_NIL,
		name = "",
		created = {},
		played = {}
	})
end
