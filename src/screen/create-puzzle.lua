class("CreatePuzzleScreen").extends(Screen)

function CreatePuzzleScreen:init()
	CreatePuzzleScreen.super.init(self)

	self.grid = Grid(true)

	self.onChanged = function () end
end

function CreatePuzzleScreen:enter(context)
	self.puzzle = context.puzzle
	self.grid:enter(self.puzzle, MODE_CREATE, HINTS_ID_OFF)
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

function CreatePuzzleScreen:flipGrid()
	self.grid:flip()
	self.puzzle.grid = self.grid.solution
end

function CreatePuzzleScreen:resetGrid()
	self.grid:reset()
	self.puzzle.grid = self.grid.solution
end

function CreatePuzzleScreen:AButtonDown()
	self:fill(true)
end

function CreatePuzzleScreen:BButtonDown()
	self.grid:startTranslating()
end

function CreatePuzzleScreen:BButtonUp()
	self.grid:endTranslating()
end

function CreatePuzzleScreen:fill(isStart)
	self.grid:toggle(self.grid:getCursor(), isStart)
end

function CreatePuzzleScreen:dpadButtonDown(dx, dy, pressed)
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self.grid:moveBy(dx, dy, pressed)
		self:fill(false)
	elseif playdate.buttonIsPressed(playdate.kButtonB) then
		self.grid:startTranslating()
		self.grid:moveBy(dx, dy, true)
		self.grid:translate()
		self.puzzle.grid = self.grid.solution
		self.onChanged()
	else
		self.grid:moveBy(dx, dy, false)
	end
end

function CreatePuzzleScreen:downButtonDown(pressed)
	self:dpadButtonDown(0, 1, pressed)
end

function CreatePuzzleScreen:leftButtonDown(pressed)
	self:dpadButtonDown(-1, 0, pressed)
end

function CreatePuzzleScreen:rightButtonDown(pressed)
	self:dpadButtonDown(1, 0, pressed)
end

function CreatePuzzleScreen:upButtonDown(pressed)
	self:dpadButtonDown(0, -1, pressed)
end

function CreatePuzzleScreen:buttonPressed(button)
	if button == playdate.kButtonDown then
		self:downButtonDown(true)
	elseif button == playdate.kButtonLeft then
		self:leftButtonDown(true)
	elseif button == playdate.kButtonRight then
		self:rightButtonDown(true)
	elseif button == playdate.kButtonUp then
		self:upButtonDown(true)
	end
end
