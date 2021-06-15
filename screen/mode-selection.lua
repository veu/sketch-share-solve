local gfx <const> = playdate.graphics

class("ModeSelection").extends(Screen)

function ModeSelection:init()
	ModeSelection.super.init(self)
	self.player = nil
	self.mode = nil

	self.sidebar = Sidebar()
	self.sidebar.onNavigated = function (index)
		self.mode = index
	end
	self.sidebar.onSelected = function ()
		self.onSelected(self.mode)
	end
	self.title = Title()
end

function ModeSelection:enter(context)
	self.mode = 1
	local sidebarConfig = {
		topText = "Playing",
		menuItems = {
			{ text = "Play" },
			{ text = "Create" },
		}
	}
	self.sidebar:enter(sidebarConfig, not playdate.isCrankDocked(), context.player)
	self.title:enter(not playdate.isCrankDocked())
end

function ModeSelection:leave()
	self.sidebar:leave()
	self.title:leave()
end

function ModeSelection:crankDocked()
	self.sidebar:close()
	self.title:setSidebarOpened(false)
end

function ModeSelection:crankUndocked()
	self.sidebar:open()
	self.title:setSidebarOpened(true)
end

function ModeSelection:cranked(change, acceleratedChange)
	self.sidebar:cranked(change, acceleratedChange)
end

function ModeSelection:AButtonDown()
	self.sidebar:AButtonDown()
end

function ModeSelection:update()
end
