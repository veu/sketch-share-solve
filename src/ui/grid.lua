local gfx <const> = playdate.graphics

class("Grid").extends(gfx.sprite)

function Grid:init(withNumbers)
	Grid.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_GRID)

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

	self.solution = {}
	self.crossed = {}
	for y = 1, puzzle.height do
		for x = 1, puzzle.width do
			local index = x - 1 + (y - 1) * puzzle.width + 1
			self.solution[index] = self.mode == MODE_CREATE and puzzle.grid[index] or 0
			self.crossed[index] =
				self.mode == MODE_PLAY and puzzle:isCellKnownEmpty(x, y) and 1
				or 0
		end
	end

	self:add()
	self.cursor:enter(puzzle)

	self:redraw()
	self:moveTo(GRID_OFFSET_X + CELL * (15 - puzzle.width), GRID_OFFSET_Y)

	if self.numbers then
		self.numbers:enter(
			puzzle,
			self.solution,
			self.crossed,
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
	if self.crossed[index] == 0 and (isStart or self.solution[index] ~= self.last) then
		self.solution[index] = self.solution[index] == 1 and 0 or 1
		self.last = self.solution[index]
		self:onUpdateSolution_()
	end
end

function Grid:toggleCross(index, isStart)
	if self.solution[index] == 0 and (isStart or self.crossed[index] ~= self.last) then
		self.crossed[index] = self.crossed[index] == 1 and 0 or 1
		self.last = self.crossed[index]
		self:onUpdateSolution_()
	end
end

function Grid:invert()
	for i = 1, #self.solution do
		self.solution[i] = self.solution[i] == 1 and 0 or 1
	end
	self:onUpdateSolution_()
end

function Grid:reset()
	for i = 1, #self.solution do
		self.solution[i] = 0
	end
	self:onUpdateSolution_()
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

function Grid:onUpdateSolution_()
	if self.numbers then
		self.numbers:updateForPosition(self.solution, self.crossed)
	end

	self:redraw()
	self.onUpdateSolution(self.solution)
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
		gfx.setFont(fontGrid)
		for y = 1, self.puzzle.height do
			for x = 1, self.puzzle.width do
				gfx.setDrawOffset(CELL * (x - 1) + 1, CELL * (y - 1) + 1)
				local index = x - 1 + (y - 1) * self.puzzle.width + 1
				if isSolved then
					if self.solution[index] == 1 then
						gfx.setColor(gfx.kColorBlack)
						gfx.fillRect(0, 0, CELL, CELL)
					end
				else
					if self.solution[index] == 1 then
						imgGrid:drawImage(2, 0, 0)
					elseif self.crossed[index] == 1 then
						imgGrid:drawImage(1, 0, 0)
					end
				end
			end
		end
	end
	gfx.unlockFocus()
	self:markDirty()
end
