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

function CreateAvatarScreen:update()
	if not playdate.isCrankDocked() then
		return
	end

	self:handleCursorDir(playdate.kButtonRight, function () self.grid:moveBy(1, 0) end)
	self:handleCursorDir(playdate.kButtonDown, function () self.grid:moveBy(0, 1) end)
	self:handleCursorDir(playdate.kButtonLeft, function () self.grid:moveBy(-1, 0) end)
	self:handleCursorDir(playdate.kButtonUp, function () self.grid:moveBy(0, -1) end)
end
