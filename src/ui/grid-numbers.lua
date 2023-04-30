class("GridNumbers").extends()

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

function GridNumbers:updateAllSolution(solution)
	self.solutionNumbers:updateAll(solution)
	self.doneNumbers:updateAll(self.solutionNumbers, solution)

	self.numbersLeft:redraw()
	self.numbersTop:redraw()
end

function GridNumbers:updateAllDone(solution)
	self.doneNumbers:updateAll(self.solutionNumbers, solution)

	self.numbersLeft:redraw()
	self.numbersTop:redraw()
end

function GridNumbers:updateForPosition(solution, mode, autoCross)
	local didAutoCrossRow = false
	local didAutoCrossColumn = false
	if mode == MODE_CREATE then
		self.gridNumbers:updatePosition(solution, self.gridX, self.gridY)
	else
		self.solutionNumbers:updatePosition(solution, self.gridX, self.gridY)
		didAutoCrossRow, didAutoCrossColumn = self.doneNumbers:updatePosition(
			self.solutionNumbers,
			solution,
			self.gridX,
			self.gridY,
			autoCross
		)
	end

	if didAutoCrossRow then
		self.numbersTop:updateAll()
	else
		self.numbersTop:updateForPosition()
	end

	if didAutoCrossColumn then
		self.numbersLeft:updateAll()
	else
		self.numbersLeft:updateForPosition()
	end

	return didAutoCrossRow or didAutoCrossColumn
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
