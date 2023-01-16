class("List").extends(gfx.sprite)

function List:init(parent)
	self.parent = parent
	List.super.init(self, gfx.image.new(SIDEBAR_WIDTH - SEPARATOR_WIDTH - 2, 240))

	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_LIST)
	self:moveTo(0, 0)

	self.onLeft = function ()
	end
end

function List:enter(context, menuItems, menuTitle)
	self.menuTitle = menuTitle
	self.menuItems = menuItems
	self.idleCounter = 0

	local selected = 1
	for i = 1, #menuItems do
		if menuItems[i].selected then
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

function List:select(index, initial)
	if not initial then
		local diff = self.cursor - index
		if diff > 1 or diff < -1 then
			playEffect("scrollFast")
		else
			playEffect("scroll")
		end
	end
	self.cursor = index
	self.needsRedraw = true
end

function List:setPosition(position)
	self.position = position

	self.needsRedraw = true
end

function List:setTarget(position)
	if self.target ~= position then
		self.target = position
		self.needNewAnimator = true
		self.idleCounter = 5
	end
end

function List:redraw()
	self.needsRedraw = self.highlightUpdate
	self.highlightUpdate = false

	gfx.setFont(fontText)
	gfx.lockFocus(self:getImage())
	do
		local x = 7
		local y = self.menuTitle and 32 or 2

		-- clear
		self:getImage():clear(gfx.kColorClear)

		if self.menuTitle then
			-- draw header
			gfx.setColor(gfx.kColorWhite)
			local width = gfx.getTextSize(self.menuTitle) + 5
			gfx.fillRect(x + 1, y + 2, width, 18)
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
		for i = math.max(1, math.floor(self.position) - 1), math.min(self.position + 6, #self.menuItems) do
			local item = self.menuItems[i]
			local y = 24 * (i - 1)
			if self.cursor ~= i then
				imgBox:drawImage(1, 0, y - 1)
			elseif item.img then
				item.img:draw(0, y - 1)
			else
				imgBox:drawImage(item.checked and 4 or 3, 0, y - 1)
			end

			local width = gfx.getTextSize(item.text) + (item.showCursor and 7 or 5)

			gfx.setColor(gfx.kColorWhite)
			gfx.fillRect(23, y, width, 18)
			if self.highlightUpdate and self.cursor == i then
				gfx.setColor(gfx.kColorBlack)
				gfx.drawRect(23, y, width, 18)
			end
			gfx.drawText(item.text, 25, y + 2)
			if item.showCursor and not self.scrollAnimator then
				gfx.setColor(gfx.kColorBlack)
				local cursorX, cursorY = gfx.getDrawOffset()
				self.textCursor:enter(
					cursorX + 20 + width,
					cursorY + y + 2
				)
			end
			if item.disabled then
				gfx.setColor(gfx.kColorBlack)
				gfx.drawLine(25, y + 9, 20 + width, y + 9)
			end
		end
	end
	gfx.unlockFocus()
	self:markDirty()
end

function List:moveTo(x, y)
	if x then
		self.x_ = x
	end
	if y then
		self.y_ = y
	end
	self:setClipRect(self.parent.x, self.parent.y, SIDEBAR_WIDTH - SEPARATOR_WIDTH - 2, 240)
	List.super.moveTo(
		self,
		self.parent.x + self.x_,
		self.parent.y + self.y_
	)
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

	if self.animator then
		self:setPosition(self.animator:currentValue())
		if self.animator:ended() then
			self.animator = nil
		end
	end

	if self.position ~= self.target then
		self.idleCounter += 1
		if (not self.animator or self.needNewAnimator) and self.idleCounter >= 5 then
			self.needNewAnimator = false
			self.animator = gfx.animator.new(
				200,
				self.position,
				self.target,
				playdate.easingFunctions.inOutSine
			)
		end
	end

	if self.needsRedraw then
		self:redraw()
	end
end
