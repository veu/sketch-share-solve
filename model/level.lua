class("Level").extends()

function Level:init(level, creator)
	self.creator = creator or 1
	self.width = 15
	self.height = 10
	self.level = level
end

function Level:isSolved(solution)
	for i, v in pairs(self.level) do
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
		if self.level[index] == 1 then
			return false
		end
	end

	return true
end

function Level:isRowKnownEmpty(cellY)
	for x = 1, self.width do
		local index = x - 1 + (cellY - 1) * self.width + 1
		if self.level[index] == 1 then
			return false
		end
	end

	return true
end

Level.createEmpty = function (creator)
	local level = {}
	for x = 1, 150 do
		table.insert(level, 0)
	end

	return Level(level, creator)
end
