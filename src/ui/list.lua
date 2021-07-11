local gfx <const> = playdate.graphics

class("List").extends(gfx.sprite)

function List:init()
	List.super.init(self)

	self.image = gfx.image.new(SIDEBAR_WIDTH - SEPARATOR_WIDTH - 2, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_LIST)
	self:setClipRect(0, 0, SIDEBAR_WIDTH - SEPARATOR_WIDTH - 2, 240)

	self.onLeft = function ()
	end
end

function List:enter(context, menuItems, menuTitle)
	self.menuTitle = menuTitle
	self.menuItems = menuItems
	self.idleCounter = 0

	local selected = 1
	for i, item in ipairs(menuItems) do
		if item.selected then
			selected = i
		end
	end

	self.cursor = selected
	self.position = math.max(1, math.min(#menuItems - 5, selected - 2))
	self.target = self.position

	self.textCursor = TextCursor()

	if context.scrolling then
		self.leaving = false
		self.scrollOut = context.scrollOut
		self.scrollAnimator = gfx.animator.new(
			400, 0, SEPARATOR_WIDTH - SIDEBAR_WIDTH, playdate.easingFunctions.inOutSine
		)
	end

	self:redraw()
	self:add()
end

function List:leave(context)
	self.textCursor:remove()
	if context.scrolling then
		self.leaving = true
		self.scrollOut = context.scrollOut
		self.scrollAnimator = gfx.animator.new(
			400, 0, SEPARATOR_WIDTH - SIDEBAR_WIDTH, playdate.easingFunctions.inOutSine
		)
	else
		self:onLeft_()
	end
end

function List:onLeft_()
	self:remove()
	self.onLeft()
end

function List:select(index)
	self.cursor = index
	self:redraw()
end

function List:setPosition(position)
	self.position = position

	self:redraw()
	self:markDirty()
end

function List:setTarget(position)
	if self.target ~= position then
		self.target = position
		self.animator = nil
		self.idleCounter = 5
	end
end

function List:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		-- draw header
		gfx.setFont(fontText)
		gfx.setColor(gfx.kColorWhite)
		local x = 7
		local y = self.menuTitle and 33 or 2

		if self.menuTitle then
			local width = gfx.getTextSize(self.menuTitle)
			gfx.fillRect(x + 1, y + 2, width + 4, 18)
			gfx.drawText(self.menuTitle, x + 3, y + 4)
		end

		-- draw arrows
		if self.position > 1 or self.target > 1 then
			imgGrid:drawImage(4, x + 2, y + 16)
		end
		if self.position < #self.menuItems - NUM_LIST_ITEMS + 1 or self.target < #self.menuItems - NUM_LIST_ITEMS + 1 then
			imgGrid:drawImage(5, x + 2, y + 152 - 5 + 24)
		end

		-- draw list
		gfx.setClipRect(x, y + 32, 188, 24 * NUM_LIST_ITEMS - 5)
		gfx.setDrawOffset(x, y + 33 - 24 * (self.position - 1))
		for i, item in ipairs(self.menuItems) do
			local y = 24 * (i - 1)
			gfx.setColor(gfx.kColorWhite)
			gfx.fillRect(0, y - 1, 19, 19)
			gfx.setColor(gfx.kColorBlack)
			if self.cursor ~= i then
				gfx.setDitherPattern(.5, gfx.image.kDitherTypeFloydSteinberg)
			end
			gfx.fillRect(1, y, 17, 17)
			gfx.setColor(gfx.kColorWhite)
			gfx.fillRect(2, y + 1, 15, 15)

			if self.cursor == i then
				local image = item.img or imgGrid:getImage(item.checked and 3 or 1)
				image:draw(2, y + 1)
			end

			local cellText = item.text
			gfx.setFont(fontText)
			gfx.setColor(gfx.kColorWhite)
			local width = gfx.getTextSize(cellText)
			if item.showCursor then
				width += 2
			end
			gfx.fillRect(23, y, width + 4, 18)
			gfx.drawText(cellText, 25, y + 2)
			if item.showCursor and not self.scrollAnimator then
				gfx.setColor(gfx.kColorBlack)
				local cursorX, cursorY = gfx.getDrawOffset()
				self.textCursor:enter(
					cursorX + 24 + width,
					cursorY + y + 2
				)
			end
			if item.disabled then
				gfx.setColor(gfx.kColorBlack)
				gfx.drawLine(25, y + 2 + 7, 25 + width, y + 2 + 7)
			end
		end
	end
	gfx.unlockFocus()
	self:markDirty()
end

function List:update()
	if self.scrollAnimator then
		local currentValue = math.floor(self.scrollAnimator:currentValue() + 0.5)
		local x = self.leaving
			and currentValue
			or SIDEBAR_WIDTH - SEPARATOR_WIDTH + currentValue
		self:moveTo(self.scrollOut and -x or x, 0)
		if self.scrollAnimator:ended() then
			self.scrollAnimator = nil
			if self.leaving then
				self:onLeft_()
			else
				self:redraw()
			end
		end
	end
	local ideal = self.target + 2
	if self.cursor <= 2 then
		if self.target > 1 then
			self:setTarget(1)
		end
	elseif self.cursor >= #self.menuItems - 1 then
		if self.target < #self.menuItems - NUM_LIST_ITEMS + 1 then
			self:setTarget(#self.menuItems - NUM_LIST_ITEMS + 1)
		end
	elseif self.cursor <= ideal - 2 then
		self:setTarget(self.target - 1)
	elseif self.cursor >= ideal + 2 then
		self:setTarget(self.target + 1)
	end

	if self.position ~= self.target then
		self.idleCounter += 1
		if self.animator then
			self:setPosition(self.animator:currentValue())
			if self.animator:ended() then
				self.animator = nil
			end
		elseif self.idleCounter >= 5 then
			self.animator = gfx.animator.new(
				200,
				self.position,
				self.target,
				playdate.easingFunctions.inOutSine
			)
		end
	end
end
