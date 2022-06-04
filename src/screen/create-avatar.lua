class("CreateAvatarScreen").extends(Screen)

function CreateAvatarScreen:init()
	CreateAvatarScreen.super.init(self)

	self.grid = Grid()
	self.frame = Frame()

	self.onChanged = function () end
end

function CreateAvatarScreen:enter(context)
	self.puzzle = Puzzle.createFromAvatar(context.player._avatar)
	context.puzzle = self.puzzle
	self.grid.onUpdateSolution = function ()
		self.puzzle.grid = self.grid.solution
		self.onChanged()
	end
	self.grid:enter(self.puzzle, MODE_AVATAR)
	self.frame:enter()
end

function CreateAvatarScreen:leave()
	self.grid:leave()
	self.frame:leave()
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

function CreateAvatarScreen:BButtonDown()
	self.grid:startTranslating()
end

function CreateAvatarScreen:BButtonUp()
	self.grid:endTranslating()
end

function CreateAvatarScreen:cross()
end

function CreateAvatarScreen:fill(isStart)
	self.grid:toggle(self.grid:getCursor(), isStart)
end

function CreateAvatarScreen:dpadButtonDown(dx, dy, pressed)
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

function CreateAvatarScreen:downButtonDown(pressed)
		self:dpadButtonDown(0, 1, pressed)
end

function CreateAvatarScreen:leftButtonDown(pressed)
	self:dpadButtonDown(-1, 0, pressed)
end

function CreateAvatarScreen:rightButtonDown(pressed)
	self:dpadButtonDown(1, 0, pressed)
end

function CreateAvatarScreen:upButtonDown(pressed)
	self:dpadButtonDown(0, -1, pressed)
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
