class("Grid").extends(gfx.sprite)

function Grid:init(withNumbers, autoCross)
	Grid.super.init(self, gfx.image.new(400 - GRID_OFFSET_X, 240 - GRID_OFFSET_Y))

	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_GRID)

	self.tilemap = gfx.tilemap.new()
	self.tilemap:setImageTable(imgGrid)

	self.onUpdateSolution = function() end

	self.cursor = Cursor()
	if withNumbers then
		self.numbers = GridNumbers()
	end
end

function Grid:enter(puzzle, mode, showHints, hintStyle, autoCross, solution)
	self.last = 0
	self.puzzle = puzzle
	self.mode = mode
	self.animator = nil
	self.autoCross = autoCross

	self.tilemap:setSize(puzzle.width, puzzle.height)

	if solution then
		self.solution = solution
	elseif self.mode == MODE_PLAY then
		self.solution = table.create(puzzle.height * puzzle.width, 0)
		local i = 1
		for y = 1, puzzle.height do
			for x = 1, puzzle.width do
				self.solution[i] = puzzle:isCellKnownEmpty(x, y) and 2 or 0
				i += 1
			end
		end
	else
		self.solution = table.shallowcopy(puzzle.grid)
	end
	self.tilemap:setTiles(self.solution, puzzle.width)

	self:add()
	self.cursor:enter(puzzle, self.mode)

	self:redraw()
	self:moveTo(
		mode == MODE_AVATAR and GRID_OFFSET_AVATAR_X or GRID_OFFSET_X + CELL * (15 - puzzle.width),
		mode == MODE_AVATAR and GRID_OFFSET_AVATAR_Y or GRID_OFFSET_Y
	)

	if self.numbers then
		self.numbers:enter(
			puzzle,
			self.solution,
			self.cursor.gridX,
			self.cursor.gridY,
			showHints,
			hintStyle
		)
		self.cursor.onMove = function (x, y)
			self.numbers:setCursor(x, y)
		end
		if solution then
			self.numbers:updateAllDone(solution)
		end
	end
end

function Grid:leave()
	self:remove()
	self.cursor:leave()
	if self.numbers then
		self.numbers:leave()
	end
	self.animator = nil
end

function Grid:updateHintStyle(hintStyle)
	self.numbers:updateHintStyle(hintStyle)
end

function Grid:toggle(index, isStart)
	local old <const> = self.solution[index]
	if old == 2 then
		if isStart then
			self.solution[index] = 0
			self.last = 0
			self:addAnimation(index, old, 0)
			self:onUpdateSolution_()
			playEffect(new == 1 and "sketch" or "erase")
		end
	elseif (isStart or old ~= self.last) then
		local new <const> = 1 - old
		self.solution[index] = new
		self.last = new
		self:addAnimation(index, old, new)
		self:onUpdateSolution_(self.autoCross and new == 1)
		playEffect(new == 1 and "sketch" or "erase")
	end
end

function Grid:toggleCross(index, isStart)
	local old <const> = self.solution[index]
	if old == 1 then
		if isStart then
			self.solution[index] = 0
			self.last = 0
			self:addAnimation(index, old, 0)
			self:onUpdateSolution_()
			playEffect(new == 2 and "cross" or "erase")
		end
	elseif (isStart or old ~= self.last) then
		local new <const> = 2 - old
		self.solution[index] = new
		self.last = new
		self:addAnimation(index, old, new)
		self:onUpdateSolution_()
		playEffect(new == 2 and "cross" or "erase")
	end
end

function Grid:addAnimation(index, old, new)
	if self.animator then
		self.tilemap:setTileAtPosition(
			self.animator.x,
			self.animator.y,
			self.animator.offset + self.animator.endValue * 5
		)
		self:redrawPosition(self.animator.x, self.animator.y)
	end

	local animator <const> = playdate.frameTimer.new(4, 1, 3)
	animator.x = self.cursor.gridX
	animator.y = self.cursor.gridY
	animator.offset = new == 0 and (old == 1 and 4 or 3) or (new == 1 and 1 or 2)
	self.animator = animator
end

function Grid:invert()
	local solution <const> = self.solution
	for i = 1, #solution do
		solution[i] = solution[i] == 1 and 0 or 1
	end

	self.tilemap:setTiles(solution, self.puzzle.width)
	if self.numbers then
		self.numbers:updateAll(solution)
	end
	self:redraw()
end

function Grid:flipX()
	local solution <const> = table.create(#self.solution, 0)
	for y = 1, self.puzzle.height do
		for x = 1, self.puzzle.width do
			local index <const> = x - 1 + (y - 1) * self.puzzle.width + 1
			local oldIndex <const> = self.puzzle.width - x + (y - 1) * self.puzzle.width + 1
			solution[index] = self.solution[oldIndex]
		end
	end

	self.solution = solution
	self.tilemap:setTiles(self.solution, self.puzzle.width)
	if self.numbers then
		self.numbers:updateAll(solution)
	end
	self:redraw()
end
function Grid:flipY()
	local solution <const> = table.create(#self.solution, 0)
	for y = 1, self.puzzle.height do
		for x = 1, self.puzzle.width do
			local index <const> = x - 1 + (y - 1) * self.puzzle.width + 1
			local oldIndex <const> = x - 1 + (self.puzzle.height - y) * self.puzzle.width + 1
			solution[index] = self.solution[oldIndex]
		end
	end

	self.solution = solution
	self.tilemap:setTiles(self.solution, self.puzzle.width)
	if self.numbers then
		self.numbers:updateAll(solution)
	end
	self:redraw()
end

function Grid:reset()
	self.solution = {}
	for y = 1, self.puzzle.height do
		for x = 1, self.puzzle.width do
			local index <const> = x - 1 + (y - 1) * self.puzzle.width + 1
			self.solution[index] =
				self.mode == MODE_PLAY and self.puzzle:isCellKnownEmpty(x, y) and 2
				or 0
		end
	end

	if self.numbers then
		self.numbers:reset(self.solution, self.mode)
	end

	self.tilemap:setTiles(self.solution, self.puzzle.width)
	self:redraw()
end

function Grid:getCursor()
	return self.cursor:getIndex()
end

function Grid:jumpTo(x, y)
	self.cursor.gridX = x
	self.cursor.gridY = y
	if self.numbers then
		self.numbers:setCursor(x, y)
	end
end

function Grid:moveBy(dx, dy, pressed)
	self.cursor:moveBy(dx, dy, pressed)
end

function Grid:hideCursor()
	self.cursor:leave()
	if self.numbers then
		self.numbers:hideCursor()
	end
end

function Grid:moveTowardsTop(step)
	self:moveTo(self.x, math.floor(GRID_OFFSET_Y * (1 - step) + 8 * step + 0.5))
end

function Grid:startTranslating()
	if not self.moveContext then
		self.moveContext = {
			startX = self.cursor.gridX,
			startY = self.cursor.gridY,
			grid = table.shallowcopy(self.solution)
		}
		self.cursor:startTranslating()
	end
end

function Grid:endTranslating()
	self.moveContext = nil
	self.cursor:endTranslating()
end

function Grid:translate()
	local dx <const> = self.cursor.gridX - self.moveContext.startX
	local dy <const> = self.cursor.gridY - self.moveContext.startY
	local grid <const> = self.moveContext.grid
	local width <const> = self.puzzle.width
	local height <const> = self.puzzle.height

	local solution <const> = table.create(#self.solution, 0)
	local index = 1
	for y = 1, height do
		for x = 1, width do
			local tx <const> = x - dx
			local ty <const> = y - dy
			if 1 <= tx and tx <= width and 1 <= ty and ty <= height then
				local translatedIndex <const> = tx - 1 + (ty - 1) * width + 1
				solution[index] = grid[translatedIndex]
			else
				solution[index] = 0
			end
			index += 1
		end
	end

	self.solution = solution
	self.tilemap:setTiles(solution, width)
	if self.numbers then
		self.numbers:updateAll(solution)
	end
	self:redraw()
end

function Grid:onUpdateSolution_(autoCross)
	if self.numbers and self.numbers:updateForPosition(self.solution, self.mode, autoCross) then
		self.tilemap:setTiles(self.solution, self.puzzle.width)
	end

	self:redrawPosition(self.cursor.gridX, self.cursor.gridY)
	self.onUpdateSolution()
end

function Grid:redrawPosition(gridX, gridY)
	local x <const> = CELL * (gridX - 1) + 1
	local y <const> = CELL * (gridY - 1) + 1
	gfx.lockFocus(self:getImage())
	do
		gfx.setColor(gfx.kColorClear)
		gfx.fillRect(x, y, CELL - 1, CELL - 1)
		self.tilemap:draw(1, 1)
	end
	gfx.unlockFocus()
	self.addDirtyRect(self.x + x, self.y + y, CELL - 1, CELL - 1)
end

function Grid:redraw()
	local width <const> = self.puzzle.width
	local height <const> = self.puzzle.height
	self:getImage():clear(gfx.kColorClear)
	gfx.lockFocus(self:getImage())
	do
		-- vertical lines
		for x = 0, width do
			gfx.setColor(gfx.kColorBlack)
			if x % 5 ~= 0 then
				gfx.setDitherPattern(0.5)
			end
			gfx.drawLine(CELL * x, 0, CELL * x, CELL * height)
		end

		-- horizontal lines
		for y = 0, height do
			gfx.setColor(gfx.kColorBlack)
			if y % 5 ~= 0 then
				gfx.setDitherPattern(0.5)
			end
			gfx.drawLine(0, CELL * y, CELL * width, CELL * y)
		end

		-- cells
		self.tilemap:draw(1, 1)
	end
	gfx.unlockFocus()
	self:markDirty()
end

function Grid:update()
	if self.animator then
		self.tilemap:setTileAtPosition(
			self.animator.x,
			self.animator.y,
			self.animator.offset + math.floor(self.animator.value) * 5
		)
		self:redrawPosition(self.animator.x, self.animator.y)
		if self.animator.value == self.animator.endValue then
			self.animator = nil
		end
	end
end
