class("GridNumbers").extends(Object)

function GridNumbers:init()
	GridNumbers.super.init()

	self.numbersLeft = GridNumbersLeft()
	self.numbersTop = GridNumbersTop()
	self.background = GridNumbersBackground()
end

function GridNumbers:enter(puzzle, solution, x, y, showHints, hintStyle)
	self.gridNumbers = Numbers(puzzle, puzzle.grid)
	self.solutionNumbers = Numbers(puzzle, solution)
	self.doneNumbers = DoneNumbers(
		puzzle,
		self.gridNumbers,
		self.solutionNumbers,
		solution
	)
	self.gridX = x
	self.gridY = y

	self.numbersLeft:enter(puzzle, self.gridNumbers, self.doneNumbers, x, y, showHints, hintStyle)
	self.numbersTop:enter(puzzle, self.gridNumbers, self.doneNumbers, x, y, showHints, hintStyle)
	self.background:enter(puzzle)
end

function GridNumbers:updateHintStyle(hintStyle)
	self.numbersLeft:updateHintStyle(hintStyle)
	self.numbersTop:updateHintStyle(hintStyle)
end

function GridNumbers:updateAll(solution)
	self.gridNumbers:updateAll(solution)

	self.numbersLeft:redraw()
	self.numbersTop:redraw()
end

function GridNumbers:updateAllDone(solution)
	self.doneNumbers:updateAll(self.solutionNumbers, solution)

	self.numbersLeft:redraw()
	self.numbersTop:redraw()
end

function GridNumbers:updateForPosition(solution, mode, autoCross)
	local didAutoCross = false
	if mode == MODE_CREATE then
		self.gridNumbers:updatePosition(solution, self.gridX, self.gridY)
	else
		self.solutionNumbers:updatePosition(solution, self.gridX, self.gridY)
		didAutoCross = self.doneNumbers:updatePosition(
			self.solutionNumbers,
			solution,
			self.gridX,
			self.gridY,
			autoCross
		)
	end

	self.numbersLeft:updateForPosition()
	self.numbersTop:updateForPosition()

	return didAutoCross
end

function GridNumbers:leave()
	self.numbersLeft:leave()
	self.numbersTop:leave()
	self.background:leave()
end

function GridNumbers:reset(solution, mode)
	if mode == MODE_CREATE then
		self.gridNumbers:updateAll(solution)
	else
		self.solutionNumbers:updateAll(solution)
		self.doneNumbers:updateAll(self.solutionNumbers, solution)
	end

	self.numbersLeft:redraw()
	self.numbersTop:redraw()
end

function GridNumbers:setCursor(x, y)
	self.gridX = x
	self.gridY = y

	self.numbersLeft:setCursor(x, y)
	self.numbersTop:setCursor(x, y)
end

function GridNumbers:hideCursor()
	self.numbersLeft:hideCursor()
	self.numbersTop:hideCursor()
end
