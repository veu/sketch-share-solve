class("Level").extends()

function Level:init(level)
	self.id = level.id
	self.title = level.title
	self.grid = level.grid
	self.width = level.width or 15
	self.height = level.height or 10

	self.hasBeenSolved = false
end

function Level:isSolved(solution)
	for i, v in pairs(self.grid) do
		if v ~= solution[i] then
			return false
		end
	end

	self.hasBeenSolved = true

	return true
end

function Level:isTrivial()
	for i, v in pairs(self.grid) do
		if v == 1 then
			return false
		end
	end

	return true
end

function Level:isCellKnownEmpty(cellX, cellY)
	return self:isColumnKnownEmpty(cellX) or self:isRowKnownEmpty(cellY)
end

function Level:isColumnKnownEmpty(cellX)
	for y = 1, self.height do
		local index = cellX - 1 + (y - 1) * self.width + 1
		if self.grid[index] == 1 then
			return false
		end
	end

	return true
end

function Level:isRowKnownEmpty(cellY)
	for x = 1, self.width do
		local index = x - 1 + (cellY - 1) * self.width + 1
		if self.grid[index] == 1 then
			return false
		end
	end

	return true
end

function Level:save(context)
	local level = {
		id = self.id,
		title = self.title,
		grid = self.grid
	}

	context.save.levels[self.id] = level
	table.insert(context.player.created, self.id)

	playdate.datastore.write(context.save)
end

function Level:delete(context)
	local levelIndex = nil
	for i, id in pairs(context.creator.created) do
		if id == self.id then
			levelIndex = i
		end
	end

	if levelIndex then
		table.remove(context.creator.created, levelIndex)
		context.creator:save(context)
	end

	context.save.levels[self.id] = nil

	playdate.datastore.write(context.save)
end

Level.load = function (context, id)
	return Level(context.save.levels[id])
end

Level.createEmpty = function (width, height)
	local grid = {}
	for x = 1, 150 do
		table.insert(grid, 0)
	end

	return Level({
		id = playdate.string.UUID(16),
		grid = grid,
		width = width or 15,
		height = height or 10
	})
end
