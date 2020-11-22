class("Level").extends()

function Level:init(level)
	self.width = 15
	self.height = 10
	self.level = level
	self.topNumbers = self:calcTopNumbers()
	self.leftNumbers = self:calcLeftNumbers()
end

function Level:isSolved(solution)
	for i, v in pairs(self.level) do
		if v ~= solution[i] then
			return false
		end
	end

	return true
end

function Level:isCellKnownEmpty(x, y)
	return
		self.topNumbers[x][1] == 0 or
		self.leftNumbers[y][1] == 0
end

function Level:calcTopNumbers()
	local topNumbers = {}
	for x = 1, self.width do
		topNumbers[x] = {}
		local i = 1
		local numbers = {}
		for y = 1, self.height do
			local index = x - 1 + (y - 1) * self.width + 1
			if self.level[index] == 1 then
				if not topNumbers[x][i] then
					topNumbers[x][i] = 1
				else
					topNumbers[x][i] += 1
				end
			elseif topNumbers[x][i] then
				i += 1
			end
		end
		if rawlen(topNumbers[x]) == 0 then
			topNumbers[x][1] = 0
		end
	end
	return topNumbers
end

function Level:calcLeftNumbers()
	local leftNumbers = {}
	for y = 1, self.height do
		leftNumbers[y] = {}
		local i = 1
		for x = 1, self.width do
			local index = x - 1 + (y - 1) * self.width + 1
			if self.level[index] == 1 then
				if not leftNumbers[y][i] then
					leftNumbers[y][i] = 1
				else
					leftNumbers[y][i] += 1
				end
			elseif leftNumbers[y][i] then
				i += 1
			end
		end
		if rawlen(leftNumbers[y]) == 0 then
			leftNumbers[y][1] = 0
		end
	end
	return leftNumbers
end
