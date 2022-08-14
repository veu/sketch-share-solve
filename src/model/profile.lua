class("Profile").extends()

function Profile:init(profile, save)
	self.id = profile.id
	self._save = save	self.name = profile.name
	self.created = profile.created
	self.createdOn = profile.createdOn
	self.played = profile.played
	self.options = profile.options or {
		showTimer = false,
		showHints = HINTS_ID_BLOCKS,
	}
	self.sketch = profile.sketch

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
		name = self.name,
		created = self.created,
		played = self.played,
		options = self.options,
		avatar = self._avatar,
		sketch = self.sketch
	}

	context.save.profiles[self.id] = profile

	local hasProfile = false
	local profileList = context.save.profileList
	for i = 1, #profileList do
		if profileList[i] == profile.id then
			hasProfile = true
			break
		end
	end

	if not hasProfile then
		table.insert(context.save.profileList, self.id)
	end
	save(context)
end

function Profile:delete(context)
	for i = 1, #self.created do
		context.save.puzzles[self.created[i]] = nil
	end

	local profileIndex = nil
	local profileList = context.save.profileList
	for i = 1, #profileList do
		if profileList[i] == self.id then
			profileIndex = i
			break
		end
	end

	if profileIndex then
		table.remove(context.save.profileList, profileIndex)
	end
	context.save.profiles[self.id] = nil

	save(context)
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

function Profile:getNumPlayedBy(creator)
	if self.id == creator.id then
		return #creator.created
	end
	local prefix = creator._save and creator._save.id .. "." or ""
	local count = 0
	local created = creator.created
	for i = 1, #created do
		if self.played[prefix .. created[i]] then
			count += 1
		end
	end
	return count
end

function Profile:playedAllBy(creator)
	if self.id == creator.id then
		return true
	end
	local prefix = creator._save and creator._save.id .. "." or ""
	local created = creator.created
	for i = 1, #created do
		if not self.played[prefix .. created[i]] then
			return false
		end
	end
	return true
end

function Profile:getTimeSpentWith(creator)
	if self.id == creator.id then
		return 0
	end
	local prefix = creator._save and creator._save.id .. "." or ""
	local time = 0
	local created = creator.created
	for i = 1, #created do
		local puzzleTime = self.played[prefix .. created[i]]
		if puzzleTime then
			time += puzzleTime
		end
	end
	return time
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
		avatar = nilAvatar,
		name = "Player",
		created = {},
		played = {}
	})
end
