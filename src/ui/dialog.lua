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

function Dialog:enter(message, callback)
	self.message = message
	self.callback = callback

	self:setVisible(true)
	self:redraw()
	self:add()
end

function Dialog:AButtonDown()
	if self.callback then
		self.callback()
		self:setVisible(false)
	end
end

function Dialog:leave()
	self:setVisible(false)
	self:remove()
end

function Dialog:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		local width = 300
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.5)
		gfx.fillRect(400 - 7 - width + 2, 7 + 2, width, 54)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(400 - 7 - width, 7, width, 54)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(400 - 6 - width, 8, width - 2, 52)

		gfx.setFont(fontText)
		gfx.drawText(self.message, 400 - 6 - width + 8, 8 + 8)

		if self.callback then
			local size = gfx.getTextSize("(A) Confirm")
			gfx.drawText("(A) Confirm", 400 - 8 - 8 - size, 8 + 8 + 22)
		end
	end
	gfx.unlockFocus()
	self:markDirty()
end
