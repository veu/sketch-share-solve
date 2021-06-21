class("GridCreate").extends(Screen)

function GridCreate:init()
	GridCreate.super.init(self)

	self.board = Board()

	self.onChanged = function () end
end

function GridCreate:enter(context)
	self.level = context.level
	self.board:enter(self.level, MODE_CREATE)
	self.board.onUpdateSolution = function (grid)
		self.level.grid = grid
		self.onChanged()
	end
end

function GridCreate:leave()
	local menu = playdate.getSystemMenu()
	menu:removeAllMenuItems()

	self.board:leave()
end

function GridCreate:invertBoard()
	self.board:invert()
end

function GridCreate:update()
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
