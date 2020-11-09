local gfx <const> = playdate.graphics

local CELL = 16

class("Board").extends(gfx.sprite)

function Board:init()
	Board.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:moveTo(CELL * 6, CELL * 4)
	self:setZIndex(5)
	self:add()
end

function Board:loadLevel(level, width, height)
	self.last = 0
	self.level = level
	self.width = width
	self.height = height
	self.solution = {}
	self.crossed = {}
	for i = 1, width * height do
		self.solution[i] = 0
		self.crossed[i] = 0
	end

	self:redraw()
end

function Board:isSolved()
	for i, v in pairs(self.level) do
		if v ~= self.solution[i] then
			return false
		end
	end

	return true
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
		gfx.fillRect(0, 0, CELL * width + 1, CELL * height + 1)
		for y = 1, height do
			for x = 1, width do
				gfx.setDrawOffset(CELL * (x - 1) + 1, CELL * (y - 1) + 1)
				local index = x - 1 + (y - 1) * width + 1
				local cell = self.level[index]
				gfx.setColor(gfx.kColorWhite)
				gfx.fillRect(0, 0, CELL - (x % 5 == 0 and 2 or 1), CELL - (y % 5 == 0 and 2 or 1))
				gfx.setColor(gfx.kColorBlack)
				if self.solution[index] == 1 then
					gfx.fillRoundRect(2, 2, CELL - 5, CELL - 5, 5)
				elseif self.crossed[index] == 1 then
					gfx.setLineWidth(.1)
					gfx.drawLine(3, 3, CELL - 5, CELL - 4)
					gfx.drawLine(3, CELL - 3, CELL - 4, 3)
				end
			end
		end
	end
	gfx.unlockFocus()
	self:markDirty()
end