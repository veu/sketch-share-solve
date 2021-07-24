class("CreateAvatarScreen").extends(Screen)

function CreateAvatarScreen:init()
	CreateAvatarScreen.super.init(self)

	self.grid = Grid()

	self.onChanged = function () end
end

function CreateAvatarScreen:enter(context)
	self.puzzle = Puzzle.createEmpty(10, 10)
	context.puzzle = self.puzzle
	self.grid:enter(self.puzzle, MODE_CREATE)
	self.grid.onUpdateSolution = function ()
		self.puzzle.grid = self.grid.solution
		self.onChanged()
	end
end

function CreateAvatarScreen:leave()
	self.grid:leave()
end

function CreateAvatarScreen:invertGrid()
	self.grid:invert()
	self.puzzle.grid = self.grid.solution
end

function CreateAvatarScreen:resetGrid()
	self.grid:reset()
	self.puzzle.grid = self.grid.solution
end

function CreateAvatarScreen:AButtonDown()
	self:fill(true)
end

function CreateAvatarScreen:cross()
end

function CreateAvatarScreen:fill(isStart)
	self.grid:toggle(self.grid:getCursor(), isStart)
end

function CreateAvatarScreen:downButtonDown(pressed)
	self.grid:moveBy(0, 1, pressed)
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self:fill(false)
	end
end

function CreateAvatarScreen:leftButtonDown(pressed)
	self.grid:moveBy(-1, 0, pressed)
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self:fill(false)
	end
end

function CreateAvatarScreen:rightButtonDown(pressed)
	self.grid:moveBy(1, 0, pressed)
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self:fill(false)
	end
end

function CreateAvatarScreen:upButtonDown(pressed)
	self.grid:moveBy(0, -1, pressed)
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self:fill(false)
	end
end

function CreateAvatarScreen:buttonPressed(button)
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
