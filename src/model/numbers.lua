class("Numbers").extends()

function Numbers:init(level, grid)
	self.level = level
	self.grid = grid

	self:calcTopNumbers()
	self:calcLeftNumbers()
end

function Numbers:calcTopNumbers()
	self.top = {}
	self.topIndexes = {}
	for x = 1, self.level.width do
		local numbers = { 0 }
		local indexes = {}
		local i = 1
		for y = 1, self.level.height do
			local index = x - 1 + (y - 1) * self.level.width + 1
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
end

function Numbers:calcLeftNumbers()
	self.left = {}
	self.leftIndexes = {}
	for y = 1, self.level.height do
		local numbers = { 0 }
		local indexes = {}
		local i = 1
		for x = 1, self.level.width do
			local index = x - 1 + (y - 1) * self.level.width + 1
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
end
