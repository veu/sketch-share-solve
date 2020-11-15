local gfx <const> = playdate.graphics

class("Numbers").extends(gfx.sprite)

function Numbers:init()
	Numbers.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:moveTo(0, 0)
	self:setZIndex(7)
	self:add()
end

function Numbers:loadLevel(level)
	self.level = level
end

function Numbers:redraw()
	gfx.lockFocus(self.image)
	self:drawLeft()
	self:drawTop()
	self:markDirty()
	gfx.unlockFocus()
end

local numMap = {
	[0] = "0",
	[1] = "1",
	[2] = "2",
	[3] = "3",
	[4] = "4",
	[5] = "5",
	[6] = "6",
	[7] = "7",
	[8] = "8",
	[9] = "9",
	[10] = "A",
	[11] = "B",
	[12] = "C",
	[13] = "D",
	[14] = "E",
	[15] = "F",
}

function Numbers:drawLeft()
	for y, numbers in pairs(self.level.leftNumbers) do
		for i, v in pairs(numbers) do
			gfx.drawText(
				numMap[v],
				CELL * (i + BOARD_OFFSET_X - 1 - rawlen(numbers)),
				CELL * (y + BOARD_OFFSET_Y - 1) + 1
			)
		end
	end
	gfx.setDitherPattern(0.5)
	for y = 0, rawlen(self.level.leftNumbers) do
		gfx.drawLine(
			CELL * (BOARD_OFFSET_X - 8), CELL * (y + BOARD_OFFSET_Y),
			CELL * (BOARD_OFFSET_X + 1), CELL * (y + BOARD_OFFSET_Y))
	end
	gfx.setDitherPattern(gfx.image.kDitherTypeNone)
end

function Numbers:drawTop()
	for x, numbers in pairs(self.level.topNumbers) do
		for i, v in pairs(numbers) do
			gfx.drawText(
				numMap[v],
				CELL * (x + BOARD_OFFSET_X - 1) + 1,
				CELL * BOARD_OFFSET_Y + 14 * (i - 1 - rawlen(numbers)) - 1
				)
		end
	end
	gfx.setDitherPattern(0.5)
	for x = 0, rawlen(self.level.topNumbers) do
		gfx.drawLine(
			CELL * (x + BOARD_OFFSET_X), CELL * (BOARD_OFFSET_Y - 5),
			CELL * (x + BOARD_OFFSET_X), CELL * (BOARD_OFFSET_Y)
		)
	end
	gfx.setDitherPattern(gfx.image.kDitherTypeNone)
end
