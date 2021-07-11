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

function Grid:enter(puzzle, mode, withHints)
	self.last = 0
	self.puzzle = puzzle
	self.mode = mode

	self.tilemap:setSize(puzzle.width, puzzle.height)

	self.solution = {}
	for y = 1, puzzle.height do
		for x = 1, puzzle.width do
			local index = x - 1 + (y - 1) * puzzle.width + 1
			self.solution[index] =
				self.mode == MODE_CREATE and puzzle.grid[index] or
				self.mode == MODE_PLAY and puzzle:isCellKnownEmpty(x, y) and 2
				or 0
		end
	end
	self.tilemap:setTiles(self.solution, puzzle.width)

	self:add()
	self.cursor:enter(puzzle)

	self:redraw()
	self:moveTo(GRID_OFFSET_X + CELL * (15 - puzzle.width), GRID_OFFSET_Y)

	if self.numbers then
		self.numbers:enter(
			puzzle,
			self.solution,
			self.cursor.gridX,
			self.cursor.gridY,
			withHints
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
end

function Grid:toggle(index, isStart)
	local old = self.solution[index]
	if old ~= 2 and (isStart or old ~= self.last) then
		local new = 1 - old
		self.solution[index] = new
		self.last = new
		self:addAnimation(index, old, new)
		self:onUpdateSolution_(index)
	end
end

function Grid:toggleCross(index, isStart)
	local old = self.solution[index]
	if old ~= 1 and (isStart or old ~= self.last) then
		local new = 2 - old
		self.solution[index] = new
		self.last = new
		self:addAnimation(index, old, new)
		self:onUpdateSolution_(index)
	end
end

function Grid:addAnimation(index, old, new)
	if self.animator then
		self.tilemap:setTileAtPosition(self.animator.x, self.animator.y, self.animator.value)
	end

	local animator = gfx.animator.new(100, 1, 4)
	animator.x = self.cursor.gridX
	animator.y = self.cursor.gridY
	animator.value = self.solution[index]
	animator.offset = new == 0 and (old == 1 and 4 or 3) or (new == 1 and 1 or 2)
	self.animator = animator
end

function Grid:invert()
	for i = 1, #self.solution do
		self.solution[i] = self.solution[i] == 1 and 0 or 1
	end

	self.tilemap:setTiles(self.solution, self.puzzle.width)
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
		self.numbers:reset(self.solution)
	end

	self.tilemap:setTiles(self.solution, self.puzzle.width)
	self:redraw()
end

function Grid:getCursor()
	return self.cursor:getIndex()
end

function Grid:moveBy(dx, dy, pressed)
	self.cursor:moveBy(dx, dy, pressed)
	self:redraw()
end

function Grid:hideCursor()
	self.cursor:leave()
end

function Grid:moveTowardsTop(step)
	self:moveTo(self.x, math.floor(GRID_OFFSET_Y * (1 - step) + 8 * step + 0.5))
end

function Grid:onUpdateSolution_(index)
	if self.numbers then
		self.numbers:updateForPosition(self.solution)
	end

	self:redraw()
	self.onUpdateSolution()
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
			self.animator.offset + math.floor(self.animator:currentValue() + 0.5) * 5
		)
		self:redraw()
		if self.animator:ended() then
			self.animator = nil
		end
	end
end
