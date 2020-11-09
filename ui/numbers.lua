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

function Numbers:loadLevel(level, width, height)
	self:calcLeft(level, width, height)
	self:calcTop(level, width, height)
end

function Numbers:redraw()
	gfx.lockFocus(self.image)
	self:drawLeft()
	self:drawTop()
	self:markDirty()
	gfx.unlockFocus()
end

local leftNumbers = {}
local topNumbers = {}

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
	for y, numbers in pairs(leftNumbers) do
		for i, v in pairs(numbers) do
			gfx.drawText(
				numMap[v],
				CELL * (i + BOARD_OFFSET_X - 1 - rawlen(numbers)),
				CELL * (y + BOARD_OFFSET_Y - 1) + 1
			)
		end
	end
	gfx.setDitherPattern(0.5)
	for y = 0, rawlen(leftNumbers) do
		gfx.drawLine(
			CELL * (BOARD_OFFSET_X - 8), CELL * (y + BOARD_OFFSET_Y),
			CELL * (BOARD_OFFSET_X + 1), CELL * (y + BOARD_OFFSET_Y))
	end
	gfx.setDitherPattern(gfx.image.kDitherTypeNone)
end

function Numbers:drawTop()
	for x, numbers in pairs(topNumbers) do
		for i, v in pairs(numbers) do
			gfx.drawText(
				numMap[v],
				CELL * (x + BOARD_OFFSET_X - 1) + 1,
				CELL * BOARD_OFFSET_Y + 14 * (i - 1 - rawlen(numbers)) - 1
				)
		end
	end
	gfx.setDitherPattern(0.5)
	for x = 0, rawlen(topNumbers) do
		gfx.drawLine(
			CELL * (x + BOARD_OFFSET_X), CELL * (BOARD_OFFSET_Y - 5),
			CELL * (x + BOARD_OFFSET_X), CELL * (BOARD_OFFSET_Y)
		)
	end
	gfx.setDitherPattern(gfx.image.kDitherTypeNone)
end

function Numbers:calcLeft(level, width, height)
	for y = 1, height do
		leftNumbers[y] = {}
		local i = 1
		for x = 1, width do
			local index = x - 1 + (y - 1) * width + 1
			if level[index] == 1 then
				if not leftNumbers[y][i] then
					leftNumbers[y][i] = 1
				else
					leftNumbers[y][i] += 1
				end
			elseif leftNumbers[y][i] then
				i += 1
			end
		end
	end
end

function Numbers:calcTop(level, width, height)
	for x = 1, width do
		topNumbers[x] = {}
		local i = 1
		local numbers = {}
		for y = 1, height do
			local index = x - 1 + (y - 1) * width + 1
			if level[index] == 1 then
				if not topNumbers[x][i] then
					topNumbers[x][i] = 1
				else
					topNumbers[x][i] += 1
				end
			elseif topNumbers[x][i] then
				i += 1
			end
		end
	end
end