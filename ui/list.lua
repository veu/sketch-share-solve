local gfx <const> = playdate.graphics

class("List").extends(gfx.sprite)

function List:init()
end

function List:enter(menuItems, menuTitle)
	local items = {}
	for i = 1, #menuItems do
		table.insert(items, menuItems[i].text)
	end
	self.listview = playdate.ui.gridview.new(0, 20)
	self.listview:setNumberOfRows(#items)
	self.listview:setSectionHeaderHeight(menuTitle and 22 or 0)
	self.listview:setContentInset(4, 0, 3, 0)
	self.listview:setCellPadding(0, 0, 4, 0)

	function self.listview:drawSectionHeader(section, x, y, width, height)
		gfx.setFont(fontText)
		gfx.setColor(gfx.kColorWhite)
		local width = gfx.getTextSize(menuTitle)
		gfx.fillRect(x + 1, y + 2, width + 4, 18)
		gfx.drawText(menuTitle, x + 3, y + 4)
	end

	function self.listview:drawCell(section, row, column, selected, x, y, width, height)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(x, y - 1, 19, 19)
		gfx.setColor(gfx.kColorBlack)
		if not selected then
			gfx.setDitherPattern(.5, playdate.graphics.image.kDitherTypeFloydSteinberg)
		end
		gfx.fillRect(x + 1, y, 17, 17)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(x + 2, y + 1, 15, 15)

		if selected then
			local image = menuItems[row].img or imgBoard:getImage(2)
			image:draw(x + 2, y + 1)
		end

		local cellText = items[row]
		gfx.setFont(fontText)
		gfx.setColor(gfx.kColorWhite)
		local width = gfx.getTextSize(cellText)
		gfx.fillRect(x + 23, y, width + 4, 18)
		gfx.drawText(cellText, x + 25, y + 2)
	end
end

function List:leave()
end

function List:select(index)
	self.listview:setSelectedRow(index)
	self.listview:scrollToRow(index)
end

function List:draw()
	self.listview:drawInRect(0, 25, 200, 205)
end
