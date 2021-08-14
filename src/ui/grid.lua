local gfx <const> = playdate.graphics

class("Grid").extends(gfx.sprite)

function Grid:init(withNumbers)
	Grid.super.init(self)

	self.image = gfx.image.new(400 - GRID_OFFSET_X, 240 - GRID_OFFSET_Y, gfx.kColorClear)
	self:setImage(self.image)
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

function Grid:enter(puzzle, mode, showHints)
	self.last = 0
	self.puzzle = puzzle
	self.mode = mode

	self.tilemap:setSize(puzzle.width, puzzle.height)

	if self.mode == MODE_PLAY then
		self.solution = {}
		for y = 1, puzzle.height do
			for x = 1, puzzle.width do
				local index = x - 1 + (y - 1) * puzzle.width + 1
				self.solution[index] = puzzle:isCellKnownEmpty(x, y) and 2 or 0
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
			showHints
		)
		self.cursor.onMove = function (x, y)
			self.numbers:setCursor(x, y)
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

function Grid:toggle(index, isStart)
	local old = self.solution[index]
	if old == 2 then
		if isStart then
			self.solution[index] = 0
			self.last = 0
			self:addAnimation(index, old, 0)
			self:onUpdateSolution_(index)
		end
	elseif (isStart or old ~= self.last) then
		local new = 1 - old
		self.solution[index] = new
		self.last = new
		self:addAnimation(index, old, new)
		self:onUpdateSolution_(index)
	end
end

function Grid:toggleCross(index, isStart)
	local old = self.solution[index]
	if old == 1 then
		if isStart then
			self.solution[index] = 0
			self.last = 0
			self:addAnimation(index, old, 0)
			self:onUpdateSolution_(index)
		end
	elseif (isStart or old ~= self.last) then
		local new = 2 - old
		self.solution[index] = new
		self.last = new
		self:addAnimation(index, old, new)
		self:onUpdateSolution_(index)
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

	local animator = playdate.frameTimer.new(2, 1, 3)
	animator.x = self.cursor.gridX
	animator.y = self.cursor.gridY
	animator.offset = new == 0 and (old == 1 and 4 or 3) or (new == 1 and 1 or 2)
	self.animator = animator
end

function Grid:invert()
	local solution = self.solution
	for i = 1, #solution do
		solution[i] = solution[i] == 1 and 0 or 1
	end

	self.tilemap:setTiles(solution, self.puzzle.width)
	self.numbers:updateAll(solution)
	self:redraw()
end

function Grid:flip()
	local solution = table.create(#self.solution, 0)
	for y = 1, self.puzzle.height do
		for x = 1, self.puzzle.width do
			local index = x - 1 + (y - 1) * self.puzzle.width + 1
			local oldIndex = self.puzzle.width - x + (y - 1) * self.puzzle.width + 1
			solution[index] = self.solution[oldIndex]
		end
	end

	self.solution = solution
	self.tilemap:setTiles(self.solution, self.puzzle.width)
	self.numbers:updateAll(solution)
	self:redraw()
end

function Grid:reset()
	self.solution = {}
	for y = 1, self.puzzle.height do
		for x = 1, self.puzzle.width do
			local index = x - 1 + (y - 1) * self.puzzle.width + 1
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

function Grid:moveBy(dx, dy, pressed)
	self.cursor:moveBy(dx, dy, pressed)
end

function Grid:hideCursor()
	self.cursor:leave()
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
	local dx = self.cursor.gridX - self.moveContext.startX
	local dy = self.cursor.gridY - self.moveContext.startY
	local grid = self.moveContext.grid

	local solution = table.create(#self.solution, 0)
	for y = 1, self.puzzle.height do
		for x = 1, self.puzzle.width do
			local index = x - 1 + (y - 1) * self.puzzle.width + 1
			if
				1 <= x - dx and x - dx <= self.puzzle.width and
				1 <= y - dy and y - dy <= self.puzzle.height
			then
				local translatedIndex = x - dx - 1 + (y - dy - 1) * self.puzzle.width + 1
				solution[index] = grid[translatedIndex]
			else
				solution[index] = 0
			end
		end
	end

	self.solution = solution
	self.tilemap:setTiles(self.solution, self.puzzle.width)
	self.numbers:updateAll(solution)
	self:redraw()
end

function Grid:onUpdateSolution_(index)
	if self.numbers then
		self.numbers:updateForPosition(self.solution, self.mode)
	end

	self:redrawPosition(self.cursor.gridX, self.cursor.gridY)
	self.onUpdateSolution()
end

function Grid:redrawPosition(gridX, gridY)
	local x = CELL * (gridX - 1) + 1
	local y = CELL * (gridY - 1) + 1
	gfx.lockFocus(self.image)
	gfx.setColor(gfx.kColorClear)
	gfx.fillRect(x, y, CELL - 1, CELL - 1)
	self.tilemap:draw(1, 1)
	gfx.unlockFocus()
	self.addDirtyRect(self.x + x, self.y + y, CELL - 1, CELL - 1)
end

function Grid:redraw()
	local isSolved = self.mode == MODE_PLAY and self.puzzle:isSolved(self.solution)
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		-- lines
		if isSolved then
			gfx.setColor(gfx.kColorBlack)
			gfx.drawRect(0, 0, CELL * self.puzzle.width + 1, CELL * self.puzzle.height + 1)
		else
			for x = 0, self.puzzle.width do
				gfx.setColor(gfx.kColorBlack)
				gfx.setDitherPattern((isSolved or x % 5 == 0) and 0 or 0.5)
				gfx.drawLine(
					CELL * x,
					0,
					CELL * x,
					CELL * self.puzzle.height + 1
				)
			end
			for y = 0, self.puzzle.height do
				gfx.setColor(gfx.kColorBlack)
				gfx.setDitherPattern((isSolved or y % 5 == 0) and 0 or 0.5)
				gfx.drawLine(
					0,
					CELL * y,
					CELL * self.puzzle.width + 1,
					CELL * y
				)
			end
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
