class("Dialog").extends(gfx.sprite)

function Dialog:init()
	Dialog.super.init(self, gfx.image.new(400, 240))

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
	self:getImage():clear(gfx.kColorClear)
	gfx.lockFocus(self:getImage())
	do
		gfx.setDrawOffset(30, 179)
		gfx.setFont(fontText)
		local size = gfx.getTextSize(self.message)
		imgDialog:drawInRect(0, 0, size + 36, 54)

		gfx.drawText(self.message, 22, 19)
	end
	gfx.unlockFocus()
	self:markDirty()
end
