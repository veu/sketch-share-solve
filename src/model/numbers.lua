class("Numbers").extends()

function Numbers:init(level, grid)
	self.level = level
	self.grid = grid

	self:calcTopNumbers()
	self:calcLeftNumbers()
end

function Numbers:calcTopNumbers()
	self.top = {}
	for x = 1, self.level.width do
		local numbers = { 0 }
		local i = 1
		for y = 1, self.level.height do
			i = self:addCellNumber(numbers, x, y, i)
		end
		if #numbers > 1 then
			table.remove(numbers)
		end
		self.top[x] = numbers
	end
end

function Numbers:calcLeftNumbers()
	self.left = {}
	for y = 1, self.level.height do
		local numbers = { 0 }
		local i = 1
		for x = 1, self.level.width do
			i = self:addCellNumber(numbers, x, y, i)
		end
		if rawlen(numbers) > 1 then
			table.remove(numbers)
		end
		self.left[y] = numbers
	end
end

function Numbers:addCellNumber(numbers, x, y, i)
	local index = x - 1 + (y - 1) * self.level.width + 1
	if self.grid[index] == 1 then
		numbers[i] += 1
		return i
	end

	if numbers[i] > 0 then
		numbers[i + 1] = 0
		return i + 1
	end

	return i
end
