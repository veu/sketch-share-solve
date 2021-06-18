class("Level").extends()

function Level:init(level)
	self.width = 15
	self.height = 10
	self.id = level.id
	self.title = level.title
	self.grid = level.grid
end

function Level:isSolved(solution)
	for i, v in pairs(self.grid) do
		if v ~= solution[i] then
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

Level.createEmpty = function ()
	local grid = {}
	for x = 1, 150 do
		table.insert(grid, 0)
	end

	return Level({
		grid = grid
	})
end
