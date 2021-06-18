local gfx <const> = playdate.graphics

class("GridList").extends(Screen)

function GridList:init()
	GridList.super.init(self)

	self.title = Title()
end

function GridList:enter(context)
	self.level = 1
	local menuItems = {}
	for i = 1, #context.save.levels[context.creator] do
		table.insert(menuItems, {
			text = "Level " .. i
		})
	end
	local sidebarConfig = {
		menuItems = menuItems,
		menuTitle = "Choose level"
	}
	self.sidebar:enter(
		sidebarConfig,
		not playdate.isCrankDocked(),
		context.player,
		context.creator
	)

	self.sidebar.onAbort = function ()
		self.onBackToCreatorSelection()
	end
	self.sidebar.onNavigated = function (index)
		self.level = index
	end
	self.sidebar.onSelected = function ()
		self.onSelectedLevel(self.level)
	end

	self.title:enter()
end

function GridList:leave()
	self.sidebar:leave()
	self.title:leave()
end
