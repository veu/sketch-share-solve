local gfx <const> = playdate.graphics

class("Dialog").extends(gfx.sprite)


function Dialog:init()
	Dialog.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_DIALOG)
	self:setVisible(false)
end

function Dialog:enter(message)
	self.message = message

	self:setVisible(true)
	self:redraw()
	self:add()
end

function Dialog:leave()
	self:setVisible(false)
	self:remove()
end

function Dialog:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.pushContext(self.image)
	do
		gfx.setDrawOffset(40, 179)
		local width = 260
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.5)
		gfx.fillRoundRect(2, 2, width, 54, 7)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRoundRect(0, 0, width, 54, 7)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(1, 1, width - 2, 52, 7)

		gfx.setFont(fontText)
		gfx.drawText(self.message, 9, 9)
	end
	gfx.popContext()
	self:markDirty()
end
