class("Puzzle").extends()

function Puzzle:init(puzzle)
	self.id = puzzle.id
	self.title = puzzle.title
	self.grid = puzzle.grid
	self.width = puzzle.width or 15
	self.height = puzzle.height or 10

	self.hasBeenSolved = false
end

function Puzzle:isSolved(solution)
	for i, v in pairs(self.grid) do
		if v ~= solution[i] & 1 then
			return false
		end
	end

	self.hasBeenSolved = true

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
		grid = self.grid
	}

	context.save.puzzles[self.id] = puzzle
	table.insert(context.player.created, self.id)

	playdate.datastore.write(context.save)
end

function Puzzle:delete(context)
	local puzzleIndex = nil
	for i, id in pairs(context.creator.created) do
		if id == self.id then
			puzzleIndex = i
		end
	end

	if puzzleIndex then
		table.remove(context.creator.created, puzzleIndex)
		context.creator:save(context)
	end

	context.save.puzzles[self.id] = nil

	playdate.datastore.write(context.save)
end

Puzzle.load = function (context, id)
	return Puzzle(context.save.puzzles[id])
end

Puzzle.createEmpty = function (width, height)
	local grid = {}
	for x = 1, 150 do
		table.insert(grid, 0)
	end

	return Puzzle({
		id = playdate.string.UUID(16),
		grid = grid,
		width = width or 15,
		height = height or 10
	})
end
