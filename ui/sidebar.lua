local gfx <const> = playdate.graphics

class("Sidebar").extends(gfx.sprite)

function Sidebar:init(menuItems)
	Sidebar.super.init(self)
	self.menuItems = menuItems
	self.opened = false
	self.animator = nil
	self.width_ = 25

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(30)
end

function Sidebar:enter(level, opened)
	self.opened = opened
	self.width_ = 200
	self.cursor = 1
	self.cursorRaw = 1.5
	self:add()
	self:redraw()
end

function Sidebar:leave()
	self:remove()
end

function Sidebar:cranked(change, acceleratedChange)
	local max = rawlen(self.menuItems)
	self.cursorRaw = (self.cursorRaw - acceleratedChange / 20 - 1 + max) % max + 1
	self.cursor = math.floor(self.cursorRaw)
	self:redraw()
end

function Sidebar:AButtonDown()
	self.menuItems[self.cursor].exec()
end

function Sidebar:open()
	self.opened = true
	self:redraw()
	self.animator = gfx.animator.new(500, 24 - self.width_, 0, playdate.easingFunctions.inOutSine)
end

function Sidebar:close()
	self.opened = false
	self:redraw()
	self.animator = gfx.animator.new(500, 0, 24 - self.width_, playdate.easingFunctions.inOutSine)
end

function Sidebar:update()
	if self.animator then
		if self.animator:ended() then
			self:moveTo(self.opened and 0 or 24 - self.width_, 0)
		else
			self:moveTo(math.floor(self.animator:currentValue()), 0)
		end
	end
end

function Sidebar:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		gfx.setFont(fontText)

		-- background
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, self.width_, 240)

		-- shadow
		if self.opened then
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(0.5)
			gfx.fillRect(self.width_, 0, 3, 240)
		end

		-- draw sidebar
		gfx.pushContext()
		gfx.setDrawOffset(self.width_ - 25, 0)
		do
			-- black borders
			gfx.setColor(gfx.kColorBlack)
			gfx.drawLine(25, 0, 25, 240)
			gfx.drawLine(0, 0, 0, 240)
			gfx.drawLine(0, 0, 0, 240)
			-- dithered background
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(0.5)
			gfx.fillRect(2, 26, 22, 240 - 52)
			gfx.setColor(gfx.kColorBlack)
			gfx.drawLine(23, 26, 23, 240 - 26)
			gfx.drawLine(2, 240 - 27, 23, 240 - 27)
		end
		gfx.popContext()

		self:drawAvatar(1, "Playing", 0)
		self:drawAvatar(4, "Creator", 240 - 24)

		-- draw menu

		-- background
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.8, gfx.image.kDitherTypeDiagonalLine)
		gfx.fillRect(1, 26, self.width_ - 27, 240 - 52)

		for i = 1, rawlen(self.menuItems) do
			gfx.pushContext()
			gfx.setDrawOffset(4, 24 * i + 5)
			do
				if self.cursor == i then
					imgAvatars:getImage(1):drawScaled(0, 2, 2)
				end
				gfx.setColor(gfx.kColorWhite)
				local width = gfx.getTextSize(self.menuItems[i].text)
				gfx.fillRect(23, 3, width + 4, 18)
				gfx.setColor(gfx.kColorBlack)
				gfx.drawText(self.menuItems[i].text, 25, 5)
			end
			gfx.popContext()
		end
	end
	gfx.unlockFocus()
	self:markDirty()
	self:moveTo(self.opened and 0 or -self.width_ + 24, 0)
end

function Sidebar:drawAvatar(id, text, y)
	local x = self.width_ - 24
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, y - 1, self.width_, 26)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, y, x - 1, 24)
	gfx.fillRect(x, y, 24, 24)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(x + 1, y + 1, 22, 22)
	imgAvatars:getImage(id):drawScaled(x + 2, y + 2, 2)
	local width = gfx.getTextSize(text)
	gfx.drawText(text, x - width - 5, y + 5)
end
