class("PlayPuzzleScreen").extends(Screen)

function PlayPuzzleScreen:init()
	PlayPuzzleScreen.super.init(self)

	self.grid = Grid(true)

	self.onPlayed = function () end
end

function PlayPuzzleScreen:enter(context)
	self.puzzle = context.puzzle
	self.mode = context.mode
	self.grid.onUpdateSolution = function (solution)
		if self.puzzle:isSolved(solution) then
			self.onPlayed()
		end
	end

	self.grid:enter(self.puzzle, MODE_PLAY, not context.player.options.hintsDisabled)
end

function PlayPuzzleScreen:leave()
	local menu = playdate.getSystemMenu()
	menu:removeAllMenuItems()

	self.grid:leave()
end

function PlayPuzzleScreen:resetBoard()
	self.grid:reset()
end

function PlayPuzzleScreen:update()
	function cross(isStart)
		self.grid:toggleCross(self.grid:getCursor(), isStart)
	end

	function fill(isStart)
		self.grid:toggle(self.grid:getCursor(), isStart)
	end

	if not playdate.isCrankDocked() or self.puzzle:isSolved(self.grid.solution) then
		return
	end

	handleFill(fill)
	handleCross(cross)
	handleCursorDir(fill, cross, playdate.kButtonRight, function (pressed) self.grid:moveBy(1, 0, pressed) end)
	handleCursorDir(fill, cross, playdate.kButtonDown, function (pressed) self.grid:moveBy(0, 1, pressed) end)
	handleCursorDir(fill, cross, playdate.kButtonLeft, function (pressed) self.grid:moveBy(-1, 0, pressed) end)
	handleCursorDir(fill, cross, playdate.kButtonUp, function (pressed) self.grid:moveBy(0, -1, pressed) end)
end
