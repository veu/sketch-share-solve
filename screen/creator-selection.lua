local gfx <const> = playdate.graphics

class("CreatorSelection").extends(Screen)

function CreatorSelection:init()
	CreatorSelection.super.init(self)
	self.creator = AVATAR_ID_RDK

	self.sidebar = Sidebar()
	self.sidebar.onNavigated = function (index)
		self.sidebar:updateData(not playdate.isCrankDocked(), self.player, index)
		self.creator = index
	end
	self.sidebar.onSelected = function ()
		self.onSelected(self.creator)
	end
	self.title = Title()
end

function CreatorSelection:enter(context)
	self.player = context.player
	local sidebarConfig = {
		topText = "Which level set?",
		menuItems = {}
	}

	for creator, value in pairs(context.save.levels) do
		table.insert(sidebarConfig.menuItems, {
			text = AVATAR_NAMES[creator]
		})
	end

	local isCrankDocked = playdate.isCrankDocked()
	self.sidebar:enter(sidebarConfig, not isCrankDocked, self.player, self.creator)
	self.title:enter(not isCrankDocked)
end

function CreatorSelection:leave()
	self.sidebar:leave()
	self.title:leave()
end

function CreatorSelection:crankDocked()
	self.sidebar:close()
	self.title:setSidebarOpened(false)
end

function CreatorSelection:crankUndocked()
	self.sidebar:updateData(not playdate.isCrankDocked(), self.player, self.creator)
	self.sidebar:open()
	self.title:setSidebarOpened(true)
end

function CreatorSelection:cranked(change, acceleratedChange)
	self.sidebar:cranked(change, acceleratedChange)
end

function CreatorSelection:AButtonDown()
	self.sidebar:AButtonDown()
end

function CreatorSelection:update()
end
