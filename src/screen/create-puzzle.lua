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

function CreatePuzzleScreen:fill(isStart)
	self.grid:toggle(self.grid:getCursor(), isStart)
end

function CreatePuzzleScreen:downButtonDown(pressed)
	self.grid:moveBy(0, 1, pressed)
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self:fill(false)
	end
end

function CreatePuzzleScreen:leftButtonDown(pressed)
	self.grid:moveBy(-1, 0, pressed)
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self:fill(false)
	end
end

function CreatePuzzleScreen:rightButtonDown(pressed)
	self.grid:moveBy(1, 0, pressed)
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self:fill(false)
	end
end

function CreatePuzzleScreen:upButtonDown(pressed)
	self.grid:moveBy(0, -1, pressed)
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self:fill(false)
	end
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
