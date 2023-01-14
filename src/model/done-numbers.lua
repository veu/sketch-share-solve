class("DoneNumbers").extends()

-- Algorithm for detecting done blocks in a row:
--- 1. Lay out blocks from the left over partial solution to get lower bound L
--- 2. Lay out blocks from the right over partial solution to get upper bound R
--- 3. For each block: tap matching blocks in partial solution in range [L,R]
--- 4. For each partial solution block: if there is only one tap, mark corresponding block as done

function DoneNumbers:init(puzzle, gridNumbers, solutionNumbers, solution)
	self.puzzle = puzzle
	self.gridNumbers = gridNumbers
	self.solutionNumbers = solutionNumbers
	self.solution = solution

	self.left = table.create(self.puzzle.height, 0)
	self.leftLine = table.create(self.puzzle.height, 0)
	for y = 1, self.puzzle.height do
		if self.gridNumbers.left[y][1] == 0 then
			self.left[y] = { true }
			self.leftLine[y] = true
		else
			self.left[y] = table.create(#self.gridNumbers.left[y], 0)
		end
	end

	self.top = table.create(self.puzzle.width, 0)
	self.topLine = table.create(self.puzzle.width, 0)
	for x = 1, self.puzzle.width do
		if self.gridNumbers.top[x][1] == 0 then
			self.top[x] = { true }
			self.topLine[x] = true
		else
			self.top[x] = table.create(#self.gridNumbers.top[x], 0)
		end
	end
end

function DoneNumbers:updatePosition(solutionNumbers, solution, x, y, autoCross)
	local doneLeft <const> = self.leftLine[y]
	local doneTop <const> = self.topLine[x]

	self.solutionNumbers = solutionNumbers
	self.solution = solution

	self:calcLeftNumbersForRow(y)
	self:calcTopNumbersForColumn(x)

	if autoCross then
		local width <const> = self.puzzle.width
		local changed = false
		if not doneLeft and self.leftLine[y] then
			for index = (y - 1) * width + 1, y * width do
				if solution[index] == 0 then
					solution[index] = 2
					changed = true
				end
			end
		end
		if not doneTop and self.topLine[x] then
			for index = x, x + (self.puzzle.height - 1) * width, width do
				if solution[index] == 0 then
					solution[index] = 2
					changed = true
				end
			end
		end
		return changed
	end
end

function DoneNumbers:updateAll(solutionNumbers, solution)
	self.solutionNumbers = solutionNumbers
	self.solution = solution

	self:calcLeftNumbers()
	self:calcTopNumbers()
end

function DoneNumbers:calcLeftNumbers()
	for y = 1, self.puzzle.height do
		self:calcLeftNumbersForRow(y)
	end
end

function DoneNumbers:calcLeftNumbersForRow(y)
	if self.gridNumbers.left[y][1] == 0 then
		local isCorrect <const> = self.solutionNumbers.left[y][1] == 0
		self.left[y][1] = isCorrect
		self.leftLine[y] = isCorrect
	else
		for i = 1, #self.gridNumbers.left[y] do
			self.left[y][i] = false
		end
		self.leftLine[y] = false
		-- layout blocks from left and right
		indexLeft, indexRight = self:matchLeft(y)

		-- identify laid out blocks in partial solution
		if indexLeft then
			self:tapBlocksLeft(y, indexLeft, indexRight)
		end
	end
end

function DoneNumbers:matchLeft(y)
	local solutionString <const> = solutionRowToString(self.puzzle, y, self.solution)
	local numbers <const> = self.gridNumbers.left[y]

	local leftIndexes <const> = {string.match(
		solutionString,
		numbersToPattern(numbers)
	)}
	if not leftIndexes[1] then
		return nil
	end

	local rightIndexes <const> = {string.match(
		string.reverse(solutionString),
		numbersToPattern(reverseNumbers(numbers))
	)}
	if not rightIndexes[1] then
		return nil
	end

	return leftIndexes, reverseIndexes(rightIndexes, self.puzzle.width)
end

function DoneNumbers:tapBlocksLeft(y, indexLeft, indexRight)
	local gridNumbers <const> = self.gridNumbers.left[y]
	local solutionNumbers <const> = self.solutionNumbers.left[y]
	local solutionIndexes <const> = self.solutionNumbers.leftIndexes[y]
	local taps <const> = {}
	for i = 1, #solutionNumbers do
		taps[i] = {}
	end

	-- tap
	for i = 1, #gridNumbers do
		local n <const> = gridNumbers[i]
		local l <const> = indexLeft[i]
		local r <const> = indexRight[i]

		for k = 1, #solutionNumbers do
			local o = solutionNumbers[k]
			if o > 0 then
				local x <const> = solutionIndexes[k]
				if n >= o and l <= x and x <= r then
					table.insert(taps[k], i)
				end
			end
		end
	end

	-- mark as done
	local numTapped = 0
	for k = 1, #taps do
		local tap <const> = taps[k]
		if #tap == 1 and solutionNumbers[k] == gridNumbers[tap[1]] then
			self.left[y][tap[1]] = true
			numTapped += 1
		end
	end
	self.leftLine[y] = numTapped == #gridNumbers
end

function DoneNumbers:calcTopNumbers()
	for x = 1, self.puzzle.width do
		self:calcTopNumbersForColumn(x)
	end
end

function DoneNumbers:calcTopNumbersForColumn(x)
	if self.gridNumbers.top[x][1] == 0 then
		local isCorrect <const> = self.solutionNumbers.top[x][1] == 0
		self.top[x][1] = isCorrect
		self.topLine[x] = isCorrect
	else
		for i = 1, #self.gridNumbers.top[x] do
			self.top[x][i] = false
		end
		self.topLine[x] = false
		-- layout blocks from both top and bottom
		indexTop, indexBottom = self:matchTop(x)

		-- identify laid out blocks in partial solution
		if indexTop then
			self:tapBlocksTop(x, indexTop, indexBottom)
		end
	end
end

function DoneNumbers:matchTop(x)
	local solutionString <const> = solutionColumnToString(self.puzzle, x, self.solution)
	local numbers <const> = self.gridNumbers.top[x]

	local topIndexes <const> = {string.match(
		solutionString,
		numbersToPattern(numbers)
	)}
	if not topIndexes[1] then
		return nil
	end

	local bottomIndexes <const> = {string.match(
		string.reverse(solutionString),
		numbersToPattern(reverseNumbers(numbers))
	)}
	if not bottomIndexes[1] then
		return nil
	end

	return topIndexes, reverseIndexes(bottomIndexes, self.puzzle.height)
end

function DoneNumbers:tapBlocksTop(x, indexTop, indexBottom)
	local gridNumbers <const> = self.gridNumbers.top[x]
	local solutionNumbers <const> = self.solutionNumbers.top[x]
	local solutionIndexes <const> = self.solutionNumbers.topIndexes[x]
	local taps <const> = {}
	for i = 1, #solutionNumbers do
		taps[i] = {}
	end

	-- tap
	for i = 1, #gridNumbers do
		local n <const> = gridNumbers[i]
		local t <const> = indexTop[i]
		local b <const> = indexBottom[i]

		for k = 1, #solutionNumbers do
			local o <const> = solutionNumbers[k]
			if o > 0 then
				local y = solutionIndexes[k]
				if n >= o and t <= y and y + o - 1 <= b then
					table.insert(taps[k], i)
				end
			end
		end
	end

	-- mark as done
	local numTapped = 0
	for k = 1, #taps do
		local tap <const> = taps[k]
		if #tap == 1 and solutionNumbers[k] == gridNumbers[tap[1]] then
			self.top[x][tap[1]] = true
			numTapped += 1
		end
	end
	self.topLine[x] = numTapped == #gridNumbers
end
