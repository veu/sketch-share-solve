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
		gfx.setDrawOffset(30, 179)

		imgDialog:drawInRect(0, 0, 274, 54)

		gfx.setFont(fontText)
		gfx.drawText(self.message, 18, 19)
	end
	gfx.popContext()
	self:markDirty()
end
