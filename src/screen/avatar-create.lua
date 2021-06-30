class("AvatarCreate").extends(Screen)

function AvatarCreate:init()
	AvatarCreate.super.init(self)

	self.board = Board()

	self.onChanged = function () end
end

function AvatarCreate:enter(context)
	self.level = Level.createEmpty(10, 10)
	context.level = self.level
	self.board:enter(self.level, MODE_CREATE)
	self.board.onUpdateSolution = function (grid)
		self.level.grid = grid
		self.onChanged()
	end
end

function AvatarCreate:leave()
	local menu = playdate.getSystemMenu()
	menu:removeAllMenuItems()

	self.board:leave()
end

function AvatarCreate:invertBoard()
	self.board:invert()
end

function AvatarCreate:resetBoard()
	self.board:reset()
end

function AvatarCreate:update()
	function cross(isStart)
		self.board:toggleCross(self.board:getCursor(), isStart)
	end

	function fill(isStart)
		self.board:toggle(self.board:getCursor(), isStart)
	end

	if not playdate.isCrankDocked() then
		return
	end

	handleFill(fill)
	handleCursorDir(fill, cross, playdate.kButtonRight, function () self.board:moveBy(1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonDown, function () self.board:moveBy(0, 1) end)
	handleCursorDir(fill, cross, playdate.kButtonLeft, function () self.board:moveBy(-1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonUp, function () self.board:moveBy(0, -1) end)
end
