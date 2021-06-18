class("GridPlay").extends(Screen)

function GridPlay:init()
	GridPlay.super.init(self)

	self.board = Board()
	self.numbers = BoardNumbers()
	self.dialog = Dialog()
end

function GridPlay:enter(context)
	self.level = context.level
	self.mode = context.mode
	self.board.onUpdateSolution = function (solution)
		if self.level:isSolved(solution) then
			self.numbers:leave()
			self.board:hideCursor()
			if self.mode == MODE_CREATE then
				self.dialog:enter("Solved! Want to save it?", self.onSave)
			end
		end
	end
	self.numbers:enter(Numbers(self.level))

	local sidebarConfig = {
		menuItems = {}
	}

	if self.mode == MODE_CREATE then
		table.insert(sidebarConfig.menuItems, {
			text = "Back to Editor",
			exec = function()
				self.onEdit()
			end
		})
	else
		table.insert(sidebarConfig.menuItems, {
			text = "Back to Overview",
			exec = function()
				self.onBackToList()
			end
		})
	end

	self.sidebar:enter(
		sidebarConfig,
		not playdate.isCrankDocked(),
		context.player,
		context.creator
	)

	self.sidebar.onAbort = function ()
		if self.mode == MODE_CREATE then
			self.onEdit()
		else
			self.onBackToList()
		end
	end
	self.board:enter(self.level, MODE_PLAY)
end

function GridPlay:leave()
	local menu = playdate.getSystemMenu()
	menu:removeAllMenuItems()

	self.board:leave()
	self.numbers:leave()
	self.sidebar:leave()
	self.dialog:leave()
end

function GridPlay:AButtonDown()
	if self.sidebar.opened then
		self.sidebar:AButtonDown()
	elseif self.dialog:isVisible() then
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

	if self.sidebar.opened or self.level:isSolved(self.board.solution) then
		return
	end

	handleFill(fill)
	handleCross(cross)
	handleCursorDir(fill, cross, playdate.kButtonRight, function () self.board:moveBy(1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonDown, function () self.board:moveBy(0, 1) end)
	handleCursorDir(fill, cross, playdate.kButtonLeft, function () self.board:moveBy(-1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonUp, function () self.board:moveBy(0, -1) end)
end
