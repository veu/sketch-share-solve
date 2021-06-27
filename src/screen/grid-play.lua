class("GridPlay").extends(Screen)

function GridPlay:init()
	GridPlay.super.init(self)

	self.board = Board()
	self.numbers = BoardNumbers()

	self.onPlayed = function () end
end

function GridPlay:enter(context)
	self.level = context.level
	self.mode = context.mode
	self.board.onUpdateSolution = function (solution, crossed)
		if self.level:isSolved(solution) then
			self.onPlayed()
		else
			self.numbers:updateForPosition(solution, crossed)
			self.board.onCursorMove = function (x, y)
				self.numbers:setCursor(x, y)
			end
		end
	end

	self.board:enter(self.level, MODE_PLAY)
	self.numbers:enter(
		self.level,
		self.board.solution,
		self.board.crossed,
		self.board.cursor.gridX,
		self.board.cursor.gridY
	)
end

function GridPlay:leave()
	local menu = playdate.getSystemMenu()
	menu:removeAllMenuItems()

	self.board:leave()
	self.numbers:leave()
end

function GridPlay:update()
	function cross(isStart)
		self.board:toggleCross(self.board:getCursor(), isStart)
	end

	function fill(isStart)
		self.board:toggle(self.board:getCursor(), isStart)
	end

	if not playdate.isCrankDocked() or self.level:isSolved(self.board.solution) then
		return
	end

	handleFill(fill)
	handleCross(cross)
	handleCursorDir(fill, cross, playdate.kButtonRight, function (pressed) self.board:moveBy(1, 0, pressed) end)
	handleCursorDir(fill, cross, playdate.kButtonDown, function (pressed) self.board:moveBy(0, 1, pressed) end)
	handleCursorDir(fill, cross, playdate.kButtonLeft, function (pressed) self.board:moveBy(-1, 0, pressed) end)
	handleCursorDir(fill, cross, playdate.kButtonUp, function (pressed) self.board:moveBy(0, -1, pressed) end)
end
