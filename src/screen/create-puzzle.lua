class("CreatePuzzleScreen").extends(Screen)

function CreatePuzzleScreen:init()
	CreatePuzzleScreen.super.init(self)

	self.grid = Grid(true)
	self.timer = Timer()

	self.onChanged = function () end
end

function CreatePuzzleScreen:enter(context)
	self.puzzle = context.puzzle

	local size = self.puzzle.width * self.puzzle.height
	self.puzzle.grid = table.create(size, 0)
	local values = {string.byte("000010111110100000100000000010000100100010010000010000000100000010011100100000010011100100000010001000100000010110110100000001000001000000000111110000", 1, size)}
	for i = 1, size do
		self.puzzle.grid[i] = values[i] - 48
	end
	self.grid.onUpdateSolution = function ()
		self.puzzle.grid = self.grid.solution
		print(table.concat(self.grid.solution), "")
		self.onChanged()
	end
	self.grid:enter(self.puzzle, MODE_CREATE, HINTS_ID_OFF)
	self.timer:enter(false, MODE_CREATE)
end

function CreatePuzzleScreen:leave()
	self.grid:leave()
	self.timer:leave()
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
