class("TutorialDialog").extends(gfx.sprite)

function TutorialDialog:init()
	TutorialDialog.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_DIALOG)
end

function TutorialDialog:enter(message)
	self.message = message

	self:redraw()
	self:add()
end

function TutorialDialog:leave()
	self:setVisible(false)
	self:remove()
end

function TutorialDialog:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.pushContext(self.image)
	do
		gfx.setDrawOffset(0, 0)
		gfx.setFont(fontText)
		local size = gfx.getTextSize(self.message)
		x, y, w, h = 25 + 7, 7, 400 - 25 - 14, 72 - 14

		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.5)
		gfx.fillRoundRect(x + 2, y + 2, w, h, 6)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(x, y, w, h, 6)
		gfx.setColor(gfx.kColorBlack)
		gfx.drawRoundRect(x, y, w, h, 6)

		gfx.drawTextInRect(self.message, x + 12, y + 11, w - 24, h, 4)
	end
	gfx.popContext()
	self:markDirty()
end
