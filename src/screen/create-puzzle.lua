class("CreatePuzzleScreen").extends(Screen)

function CreatePuzzleScreen:init()
	CreatePuzzleScreen.super.init(self)

	self.grid = Grid()

	self.onChanged = function () end
end

function CreatePuzzleScreen:enter(context)
	self.puzzle = context.puzzle
	self.grid:enter(self.puzzle, MODE_CREATE)
	self.grid.onUpdateSolution = function ()
		self.puzzle.grid = self.grid.solution
		self.onChanged()
	end
end

function CreatePuzzleScreen:leave()
	local menu = playdate.getSystemMenu()
	menu:removeAllMenuItems()

	self.grid:leave()
end

function CreatePuzzleScreen:invertGrid()
	self.grid:invert()
	self.puzzle.grid = self.grid.solution
end

function CreatePuzzleScreen:resetGrid()
	self.grid:reset()
	self.puzzle.grid = self.grid.solution
end

function CreatePuzzleScreen:update()
	function cross(isStart)
		self.grid:toggleCross(self.grid:getCursor(), isStart)
	end

	function fill(isStart)
		self.grid:toggle(self.grid:getCursor(), isStart)
	end

	if not playdate.isCrankDocked() then
		return
	end

	handleFill(fill)
	handleCursorDir(fill, cross, playdate.kButtonRight, function () self.grid:moveBy(1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonDown, function () self.grid:moveBy(0, 1) end)
	handleCursorDir(fill, cross, playdate.kButtonLeft, function () self.grid:moveBy(-1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonUp, function () self.grid:moveBy(0, -1) end)
end
