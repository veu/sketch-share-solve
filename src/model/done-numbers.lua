class("DoneNumbers").extends()

function DoneNumbers:init(level, gridNumbers, solutionNumbers, crossed)
	self.level = level
	self.gridNumbers = gridNumbers
	self.solutionNumbers = solutionNumbers

	self:calcLeftNumbers()
	self:calcTopNumbers()
end

function DoneNumbers:calcLeftNumbers()
	self.left = {}
	for y = 1, self.level.height do
		self.left[y] = {}

		-- default to false
		for i, v in pairs(self.gridNumbers.left[y]) do
			self.left[y][i] = false
		end

		-- test all equal with solution
		if #self.gridNumbers.left[y] == #self.solutionNumbers.left[y] then
			for i, v in pairs(self.gridNumbers.left[y]) do
				self.left[y][i] = v == self.solutionNumbers.left[y][i]
			end
		end
	end
end

function DoneNumbers:calcTopNumbers()
	self.top = {}
	for x = 1, self.level.width do
		self.top[x] = {}

		-- default to false
		for i, v in pairs(self.gridNumbers.top[x]) do
			self.top[x][i] = false
		end

		-- test all equal with solution
		if #self.gridNumbers.top[x] == #self.solutionNumbers.top[x] then
			for i, v in pairs(self.gridNumbers.top[x]) do
				self.top[x][i] = v == self.solutionNumbers.top[x][i]
			end
		end
	end
end
