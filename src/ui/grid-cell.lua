local gfx <const> = playdate.graphics

class("GridCell").extends(gfx.sprite)

function GridCell:init()
	GridCell.super.init(self)

	self.image = gfx.image.new(16, 16, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_GRID_ANIM)
end

function GridCell:enter(puzzle, index, current, last)
	self.puzzle = puzzle
	self.animator = gfx.animator.new(100, 1, 4)
	self.offset = current == 0 and (last == 1 and 4 or 3) or (current == 1 and 2 or 1)

	self:moveTo(
		GRID_OFFSET_X + CELL * (15 - self.puzzle.width) + CELL * ((index - 1) % puzzle.width) + 1,
		GRID_OFFSET_Y + CELL * (math.floor((index - 1) / puzzle.width)) + 1
	)

	self:add()
end

function GridCell:leave()
	self:remove()
end

function GridCell:redraw()
	self.image:clear(gfx.kColorWhite)
	gfx.lockFocus(self.image)
	do
		imgGrid:drawImage(self.offset + math.floor(self.animator:currentValue() + 0.5) * 5, 0, 0)
	end
	gfx.unlockFocus()

	self:markDirty()
end

function GridCell:update()
	if self.animator then
		if self.animator:ended() then
			self:remove()
			self.animator = nil
		else
			self:redraw()
		end
	end
end
