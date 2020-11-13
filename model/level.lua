class("Level").extends()

function Level:init(level, width, height)
	self.solution = solution
	self.level = level
	self.topNumbers = self:calcTopNumbers(width, height)
	self.leftNumbers = self:calcLeftNumbers(width, height)
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

function Level:calcTopNumbers(width, height)
	local topNumbers = {}
	for x = 1, width do
		topNumbers[x] = {}
		local i = 1
		local numbers = {}
		for y = 1, height do
			local index = x - 1 + (y - 1) * width + 1
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

function Level:calcLeftNumbers(width, height)
	local leftNumbers = {}
	for y = 1, height do
		leftNumbers[y] = {}
		local i = 1
		for x = 1, width do
			local index = x - 1 + (y - 1) * width + 1
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
