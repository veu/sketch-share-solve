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

function CreatePuzzleScreen:AButtonDown()
	self:fill(true)
end

function CreatePuzzleScreen:cross()
end

function CreatePuzzleScreen:fill(isStart)
	self.grid:toggle(self.grid:getCursor(), isStart)
end

function CreatePuzzleScreen:update()
	if not playdate.isCrankDocked() then
		return
	end

	self:handleCursorDir(playdate.kButtonRight, function () self.grid:moveBy(1, 0) end)
	self:handleCursorDir(playdate.kButtonDown, function () self.grid:moveBy(0, 1) end)
	self:handleCursorDir(playdate.kButtonLeft, function () self.grid:moveBy(-1, 0) end)
	self:handleCursorDir(playdate.kButtonUp, function () self.grid:moveBy(0, -1) end)
end
