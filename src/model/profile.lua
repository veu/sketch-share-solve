class("Profile").extends()

function Profile:init(profile, save)
	self.id = profile.id
	self._save = save
	self.hidden = profile.hidden or false
	self.name = profile.name
	self.created = profile.created
	self.played = profile.played
	self.options = profile.options or {}

	if profile.avatar then
		self._avatar = profile.avatar
		self.avatar = loadAvatar(profile.avatar)
	else
		local id = AVATAR_ID_NIL
		self.avatar = imgAvatars:getImage(AVATAR_ID_NIL)
	end
end

function Profile:save(context)
	local profile = {
		id = self.id,
		hidden = self.hidden,
		name = self.name,
		created = self.created,
		played = self.played,
		options = self.options,
		avatar = self._avatar
	}

	context.save.profiles[self.id] = profile

	local hasProfile = false
	for _, id in pairs(context.save.profileList) do
		if id == profile.id then
			hasProfile = true
		end
	end

	if not hasProfile then
		table.insert(context.save.profileList, self.id)
	end
	save(context)
end

function Profile:delete(context)
	-- hide profile if player has created puzzles
	if #self.created > 0 then
		self.hidden = true
		self:save(context)
	else
		local profileIndex = nil
		for i, id in pairs(context.save.profileList) do
			if id == self.id then
				profileIndex = i
			end
		end

		if profileIndex then
			table.remove(context.save.profileList, profileIndex)
		end
		context.save.profiles[self.id] = nil

		save(context)
	end
end

function Profile:setAvatar(avatar)
	self.avatar = avatar
	self._avatar = saveAvatar(avatar)
end

function Profile:getNumPlayed()
	local numPlayed = 0
	for _ in pairs(self.played) do
		numPlayed += 1
	end
	return numPlayed
end

function Profile:playedAllBy(creator)
	if self.id == creator.id then
		return true
	end
	local prefix = creator._save and creator._save.id .. "." or ""
	for _, id in pairs(creator.created) do
		if not self.played[prefix .. id] then
			return false
		end
	end
	return true
end

function Profile:hasPlayed(puzzle)
	local id = puzzle._save and puzzle._save.id .. "." .. puzzle.id or puzzle.id
	return self.played[id]
end

function Profile:setPlayed(puzzle, time)
	local id = puzzle._save and puzzle._save.id .. "." .. puzzle.id or puzzle.id
	if not self.played[id] or time < 0 + self.played[id] then
		self.played[id] = time
	end
end

Profile.load = function (context, id, save)
	return Profile((save or context.save).profiles[id], save)
end

function Profile.createEmpty()
	return Profile({
		id = playdate.string.UUID(16),
		hidden = false,
		avatar = saveAvatar(imgAvatars:getImage(AVATAR_ID_NIL)),
		name = "Player",
		created = {},
		played = {}
	})
end
