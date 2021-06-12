local gfx <const> = playdate.graphics

class("TitleScreen").extends(Screen)

function TitleScreen:init()
	TitleScreen.super.init(self)

	self.sidebar = TitleSidebar({
		{ text = "Sweet Snail" },
		{ text = "Calm Cat" },
		{ text = "Mindful Mouse" },
		{ text = "Reliable Raccoon"}
	})
	self.title = Title()
end

function TitleScreen:enter()
	self.sidebar:enter(not playdate.isCrankDocked())
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
	self.onSelected(self.sidebar.cursor + 1)
end

function TitleScreen:update()
end
