local gfx <const> = playdate.graphics

class("TitleScreen").extends(Screen)

function TitleScreen:init()
	TitleScreen.super.init(self)
	self.player = 2

	self.sidebar = Sidebar()
	self.sidebar.onNavigated = function (index)
		self.sidebar:updateData(not playdate.isCrankDocked(), index + 1)
		self.player = index + 1
	end
	self.sidebar.onSelected = function ()
		self.onSelected(self.player)
	end
	self.title = Title()
end

function TitleScreen:enter()
	local sidebarConfig = {
		topText = "Who is playing?",
		menuItems = {
			{ text = "Suave Snail" },
			{ text = "Charming Cat" },
			{ text = "Mindful Mouse" },
			{ text = "Reliable Raccoon"}
		}
	}
	self.sidebar:enter(sidebarConfig, not playdate.isCrankDocked(), 2)
	self.title:enter(not playdate.isCrankDocked())
end

function TitleScreen:leave()
	self.sidebar:leave()
	self.title:leave()
end

function TitleScreen:crankDocked()
	self.sidebar:close()
	self.title:setSidebarOpened(false)
end

function TitleScreen:crankUndocked()
	self.sidebar:open()
	self.title:setSidebarOpened(true)
end

function TitleScreen:cranked(change, acceleratedChange)
	self.sidebar:cranked(change, acceleratedChange)
end

function TitleScreen:AButtonDown()
	self.sidebar:AButtonDown()
end

function TitleScreen:update()
end
