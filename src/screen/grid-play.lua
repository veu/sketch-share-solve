class("GridPlay").extends(Screen)

function GridPlay:init()
	GridPlay.super.init(self)

	self.board = Board()
	self.numbers = BoardNumbers()
	self.dialog = Dialog()

	self.onPlayed = function () end
end

function GridPlay:enter(context)
	self.level = context.level
	self.mode = context.mode
	self.board.onUpdateSolution = function (solution)
		if self.level:isSolved(solution) then
			self.numbers:leave()
			self.board:hideCursor()
			if self.mode == MODE_CREATE then
				self.onReadyToSave()
				self.dialog:enter("Solved! Ready to save.")
			else
				self.onPlayed(self.level)
				self.dialog:enter(self.level.title and "Solved: " .. self.level.title or "Solved!")
			end
		end
	end
	self.numbers:enter(Numbers(self.level))

	self.board:enter(self.level, MODE_PLAY)
end

function GridPlay:leave()
	local menu = playdate.getSystemMenu()
	menu:removeAllMenuItems()

	self.board:leave()
	self.numbers:leave()
	self.dialog:leave()
end

function GridPlay:AButtonDown()
	if self.dialog:isVisible() then
		self.dialog:AButtonDown()
	end
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
	handleCursorDir(fill, cross, playdate.kButtonRight, function () self.board:moveBy(1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonDown, function () self.board:moveBy(0, 1) end)
	handleCursorDir(fill, cross, playdate.kButtonLeft, function () self.board:moveBy(-1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonUp, function () self.board:moveBy(0, -1) end)
end
