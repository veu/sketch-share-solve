local gfx <const> = playdate.graphics

class("Board").extends(gfx.sprite)

function Board:init()
	Board.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:moveTo(CELL * BOARD_OFFSET_X, CELL * BOARD_OFFSET_Y)
	self:setZIndex(5)
	self:add()
end

function Board:loadLevel(level)
	self.last = 0
	self.level = level

	self.solution = {}
	self.crossed = {}
	for y = 1, level.height do
		for x = 1, level.width do
			local index = x - 1 + (y - 1) * level.width + 1
			self.solution[index] = 0
			self.crossed[index] = level:isCellKnownEmpty(x, y) and 1 or 0
		end
	end

	self:redraw()
end

function Board:toggle(index, isStart)
	if self.crossed[index] == 0 and (isStart or self.solution[index] ~= self.last) then
		self.solution[index] = self.solution[index] == 1 and 0 or 1
		self.last = self.solution[index]
		self:redraw()
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
	gfx.lockFocus(self.image)
	do
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