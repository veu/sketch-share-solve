class("Puzzle").extends()

function Puzzle:init(puzzle, save)
	self.id = puzzle.id
	self._save = save
	self.title = puzzle.title
	self.width = puzzle.width or 15
	self.height = puzzle.height or 10

	local size = self.width * self.height
	self.grid = table.create(size, 0)
	local values = {string.byte(puzzle.grid, 1, size)}
	for i = 1, size do
		self.grid[i] = values[i] - 48
	end

	self.hasBeenSolved = false
end

function Puzzle:isSolved(solution)
	local grid = self.grid
	for i = 1, self.width * self.height do
		if grid[i] ~= solution[i] & 1 then
			return false
		end
	end

	self.hasBeenSolved = true
	
	print("puzzle solved!")
	-- Play victory fanfare
	if currentSong ~= "none" then MusicPlayer:stopSound() end
	local function restart_music()	
		if currentSong ~= "none" then 
			--songs[currentSong]:play(0) 
			MusicPlayer:playSong()
		end 
	end
	sfxManager:playWithCallback("victory", restart_music)
	--playdate.sound.sampleplayer:setFinishCallback(func, [arg])

	return true
end

function Puzzle:isTrivial()
	for i, v in ipairs(self.grid) do
		if v == 1 then
			return false
		end
	end

	return true
end

function Puzzle:isCellKnownEmpty(cellX, cellY)
	return self:isColumnKnownEmpty(cellX) or self:isRowKnownEmpty(cellY)
end

function Puzzle:isColumnKnownEmpty(cellX)
	for y = 1, self.height do
		local index = cellX - 1 + (y - 1) * self.width + 1
		if self.grid[index] == 1 then
			return false
		end
	end

	return true
end

function Puzzle:isRowKnownEmpty(cellY)
	for x = 1, self.width do
		local index = x - 1 + (cellY - 1) * self.width + 1
		if self.grid[index] == 1 then
			return false
		end
	end

	return true
end

function Puzzle:save(context)
	local puzzle = {
		id = self.id,
		title = self.title,
		grid = table.concat(self.grid)
	}

	context.save.puzzles[self.id] = puzzle
	table.insert(context.player.created, self.id)

	save(context)
end

function Puzzle:delete(context)
	local puzzleIndex = nil
	local created = context.creator.created
	for i = 1, #created do
		if created[i] == self.id then
			puzzleIndex = i
			break
		end
	end

	if puzzleIndex then
		table.remove(created, puzzleIndex)
	end

	context.save.puzzles[self.id] = nil

	save(context)
end

Puzzle.load = function (context, id, save)
	return Puzzle((save or context.save).puzzles[id], save)
end

Puzzle.createEmpty = function (width, height)
	width = width or 15
	height = height or 10

	return Puzzle({
		id = playdate.string.UUID(16),
		grid = string.rep("0", width * height),
		width = width,
		height = height,
		title = "",
	})
end

Puzzle.createFromAvatar = function (avatar)
	if avatar == nilAvatar then
		return Puzzle.createEmpty(10, 10)
	end

	return Puzzle({
		id = playdate.string.UUID(16),
		grid = avatar,
		width = 10,
		height = 10,
		title = "",
	})
end
