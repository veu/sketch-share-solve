class("Numbers").extends()

function Numbers:init(puzzle, grid)
	self.puzzle = puzzle
	self.grid = grid

	self:calcTopNumbers()
	self:calcLeftNumbers()
end

function Numbers:updatePosition(grid, x, y)
	self.grid = grid

	self:calcLeftNumbersForRow(y)
	self:calcTopNumbersForColumn(x)
end

function Numbers:calcTopNumbers()
	local width = self.puzzle.width
	self.top = table.create(width, 0)
	self.topIndexes = table.create(width, 0)
	for x = 1, width do
		self:calcTopNumbersForColumn(x)
	end
end

function Numbers:calcTopNumbersForColumn(x)
	local numbers = { 0 }
	local indexes = {}
	local i = 1
	for y = 1, self.puzzle.height do
		local index = x - 1 + (y - 1) * self.puzzle.width + 1
		if self.grid[index] == 1 then
			if numbers[i] == 0 then
				indexes[i] = y
			end
			numbers[i] += 1
		elseif numbers[i] > 0 then
			numbers[i + 1] = 0
			i += 1
		end
	end
	if #numbers > 1 and numbers[#numbers] == 0 then
		table.remove(numbers)
	end
	self.top[x] = numbers
	self.topIndexes[x] = indexes
end

function Numbers:calcLeftNumbers()
	local height = self.puzzle.height
	self.left = table.create(height, 0)
	self.leftIndexes = table.create(height, 0)
	for y = 1, height do
		self:calcLeftNumbersForRow(y)
	end
end

function Numbers:calcLeftNumbersForRow(y)
	local numbers = { 0 }
	local indexes = {}
	local i = 1
	for x = 1, self.puzzle.width do
		local index = x - 1 + (y - 1) * self.puzzle.width + 1
		if self.grid[index] == 1 then
			if numbers[i] == 0 then
				indexes[i] = x
			end
			numbers[i] += 1
		elseif numbers[i] > 0 then
			numbers[i + 1] = 0
			i += 1
		end
	end
	if #numbers > 1 and numbers[#numbers] == 0 then
		table.remove(numbers)
	end
	self.left[y] = numbers
	self.leftIndexes[y] = indexes
end
