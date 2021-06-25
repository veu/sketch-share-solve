class("DoneNumbers").extends()

-- Algorithm for detecting done blocks in a row:
--- 1. Lay out blocks from the left over partial solution to get lower bound L
--- 2. Lay out blocks from the right over partial solution to get upper bound R
--- 3. For each block: tap matching blocks in partial solution in range [L,R]
--- 4. For each partial solution block: if there is only one tap, mark corresponding block as done

function DoneNumbers:init(level, gridNumbers, solutionNumbers, crossed, solution)
	self.level = level
	self.gridNumbers = gridNumbers
	self.solutionNumbers = solutionNumbers
	self.crossed = crossed
	self.solution = solution

	self:calcLeftNumbers()
	self:calcTopNumbers()
end

function DoneNumbers:calcLeftNumbers()
	self.left = {}
	for y = 1, self.level.height do
		self.left[y] = {}

		-- layout blocks from left and right
		indexLeft, indexRight = self:matchLeft(y)

		-- identify laid out blocks in partial solution
		if indexLeft then
			self:tapBlocksLeft(y, indexLeft, indexRight)
		end
	end
end

function DoneNumbers:matchLeft(y)
	local solutionString = solutionRowToString(self.level, y, self.solution, self.crossed)
	local numbers = self.gridNumbers.left[y]

	local leftIndexes = {string.match(
		solutionString,
		numbersToPattern(numbers)
	)}
	if not leftIndexes[1] then
		return nil
	end

	local rightIndexes = {string.match(
		string.reverse(solutionString),
		numbersToPattern(reverseNumbers(numbers))
	)}
	if not rightIndexes[1] then
		return nil
	end

	return leftIndexes, reverseIndexes(rightIndexes, self.level.width)
end

function DoneNumbers:tapBlocksLeft(y, indexLeft, indexRight)
	local taps = {}
	for i = 1, #self.solutionNumbers.left[y] do
		taps[i] = {}
	end

	-- tap
	for i, n in pairs(self.gridNumbers.left[y]) do
		local l = indexLeft[i]
		local r = indexRight[i]

		for k, o in pairs(self.solutionNumbers.left[y]) do
			if o > 0 then
				local x = self.solutionNumbers.leftIndexes[y][k]
				if n >= o and l <= x and x <= r then
					table.insert(taps[k], i)
				end
			end
		end
	end

	-- mark as done
	for k, tap in pairs(taps) do
		if #tap == 1 and self.solutionNumbers.left[y][k] == self.gridNumbers.left[y][tap[1]] then
			self.left[y][tap[1]] = true
		end
	end
end

function DoneNumbers:calcTopNumbers()
	self.top = {}
	for x = 1, self.level.width do
		self.top[x] = {}

		-- layout blocks from both top and bottom
		indexTop, indexBottom = self:matchTop(x)

		-- identify laid out blocks in partial solution
		if indexTop then
			self:tapBlocksTop(x, indexTop, indexBottom)
		end
	end
end

function DoneNumbers:matchTop(x)
	local solutionString = solutionColumnToString(self.level, x, self.solution, self.crossed)
	local numbers = self.gridNumbers.top[x]

	local topIndexes = {string.match(
		solutionString,
		numbersToPattern(numbers)
	)}
	if not topIndexes[1] then
		return nil
	end

	local bottomIndexes = {string.match(
		string.reverse(solutionString),
		numbersToPattern(reverseNumbers(numbers))
	)}
	if not bottomIndexes[1] then
		return nil
	end

	return topIndexes, reverseIndexes(bottomIndexes, self.level.height)
end

function DoneNumbers:tapBlocksTop(x, indexTop, indexBottom)
	local taps = {}
	for i = 1, #self.solutionNumbers.top[x] do
		taps[i] = {}
	end

	-- tap
	for i, n in pairs(self.gridNumbers.top[x]) do
		local t = indexTop[i]
		local b = indexBottom[i]

		for k, o in pairs(self.solutionNumbers.top[x]) do
			if o > 0 then
				local y = self.solutionNumbers.topIndexes[x][k]
				if n >= o and t <= y and y + o - 1 <= b then
					table.insert(taps[k], i)
				end
			end
		end
	end

	-- mark as done
	for k, tap in pairs(taps) do
		if #tap == 1 and self.solutionNumbers.top[x][k] == self.gridNumbers.top[x][tap[1]] then
			self.top[x][tap[1]] = true
		end
	end
end
