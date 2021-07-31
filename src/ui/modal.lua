local gfx <const> = playdate.graphics

class("Modal").extends(gfx.sprite)

function Modal:init()
	Modal.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_MODAL)
	self:setVisible(false)

	self.onOK = function () end
	self.onCancel = function () end
end

function Modal:enter(text, ok, dismiss)
	self:setVisible(true)
	self:draw(text, ok, dismiss)
	self:add()
end

function Modal:leave()
	self.onOK = function () end
	self.onCancel = function () end
	self:setVisible(false)
	self:remove()
end

function Modal:AButtonDown()
	self.onClose()
	self.onOK()
	self:leave()
end

function Modal:BButtonDown()
	self.onClose()
	self.onCancel()
	self:leave()
end

function Modal:draw(text, ok, cancel)
	self.image:clear(gfx.kColorClear)
	gfx.pushContext(self.image)
	do
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.5)
		gfx.fillRect(0, 0, 400, 240)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(20, 20, 360, 200, 8)
		gfx.setColor(gfx.kColorBlack)
		gfx.drawRoundRect(20, 20, 360, 200, 8)
		gfx.setFont(fontText)
		gfx.drawTextInRect(text, 40, 40, 320, 160)

		drawButton(playdate.kButtonB, cancel or "Cancel", 40, 180)
		drawButton(playdate.kButtonA, ok or "OK", 86 + gfx.getTextSize(cancel or "Cancel"), 180)
	end
	gfx.popContext()
	self:markDirty()
end
