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

function Board:redraw(level, SOLUTION, MARKED)
	gfx.lockFocus(self.image)
	do
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(0, 0, CELL * width + 1, CELL * height + 1)
		for y = 1, height do
			for x = 1, width do
				gfx.setDrawOffset(CELL * (x - 1) + 1, CELL * (y - 1) + 1)
				local index = x - 1 + (y - 1) * width + 1
				local cell = level[index]
				gfx.setColor(gfx.kColorWhite)
				gfx.fillRect(0, 0, CELL - (x % 5 == 0 and 2 or 1), CELL - (y % 5 == 0 and 2 or 1))
				gfx.setColor(gfx.kColorBlack)
				if SOLUTION[index] == 1 then
					gfx.fillRoundRect(2, 2, CELL - 5, CELL - 5, 5)
				elseif MARKED[index] then
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