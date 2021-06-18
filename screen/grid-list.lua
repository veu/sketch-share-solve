local gfx <const> = playdate.graphics

class("GridList").extends(Screen)

function GridList:init()
	GridList.super.init(self)

	self.title = Title()
end

function GridList:enter(context)
	local menuItems = {}
	for i, id in pairs(context.creator.created) do
		local level = context.save.levels[id]
		assert(level)
		table.insert(menuItems, {
			text = level.title or "Level " .. i, -- TODO: only show name for played
			ref = level
		})

	end
	local sidebarConfig = {
		menuItems = menuItems,
		menuTitle = "Choose level"
	}
	self.sidebar:enter(
		sidebarConfig,
		not playdate.isCrankDocked(),
		context.player.avatar,
		context.creator.avatar
	)

	self.sidebar.onAbort = function ()
		self.onBackToCreatorSelection()
	end
	self.sidebar.onSelected = function (level)
		self.onSelectedLevel(level)
	end

	self.title:enter()
end

function GridList:leave()
	self.sidebar:leave()
	self.title:leave()
end
