local gfx <const> = playdate.graphics

class("Board").extends(gfx.sprite)

function Board:init()
	Board.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:moveTo(CELL * BOARD_OFFSET_X, CELL * BOARD_OFFSET_Y)
	self:setZIndex(5)

	self.onUpdateSolution = function() end
end

function Board:enter(level, mode)
	self.last = 0
	self.level = level
	self.mode = mode

	self.solution = {}
	self.crossed = {}
	for y = 1, level.height do
		for x = 1, level.width do
			local index = x - 1 + (y - 1) * level.width + 1
			self.solution[index] = self.mode == MODE_CREATE and level.level[index] or 0
			self.crossed[index] =
				self.mode == MODE_PLAY and level:isCellKnownEmpty(x, y) and 1
				or 0
		end
	end

	self:redraw()
	self:add()
end

function Board:leave()
	self:remove()
end

function Board:toggle(index, isStart)
	if self.crossed[index] == 0 and (isStart or self.solution[index] ~= self.last) then
		self.solution[index] = self.solution[index] == 1 and 0 or 1
		self.last = self.solution[index]
		self:redraw()
		self.onUpdateSolution(self.solution)
	end
end

function Board:toggleCross(index, isStart)
	if self.solution[index] == 0 and (isStart or self.crossed[index] ~= self.last) then
		self.crossed[index] = self.crossed[index] == 1 and 0 or 1
		self.last = self.crossed[index]
		self:redraw()
	end
end

function Board:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		gfx.setFont(fontGrid)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(0, 0, CELL * self.level.width + 1, CELL * self.level.height + 1)
		for y = 1, self.level.height do
			for x = 1, self.level.width do
				gfx.setDrawOffset(CELL * (x - 1) + 1, CELL * (y - 1) + 1)
				local index = x - 1 + (y - 1) * self.level.width + 1
				gfx.setColor(gfx.kColorWhite)
				gfx.fillRect(0, 0, CELL - (x % 5 == 0 and 2 or 1), CELL - (y % 5 == 0 and 2 or 1))
				gfx.setColor(gfx.kColorBlack)
				if self.solution[index] == 1 then
					gfx.drawText("o", 0, 0)
				elseif self.crossed[index] == 1 then
					gfx.drawText("x", 0, 0)
				end
			end
		end
	end
	gfx.unlockFocus()
	self:markDirty()
end
