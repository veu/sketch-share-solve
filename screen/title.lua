local gfx <const> = playdate.graphics

class("TitleScreen").extends(Screen)

function TitleScreen:init()
	TitleScreen.super.init(self)
	self.player = 1

	self.sidebar = Sidebar()
	self.sidebar.onNavigated = function (index)
		self.sidebar:updateData(not playdate.isCrankDocked(), index)
		self.player = index
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
	local isCrankDocked = playdate.isCrankDocked()
	self.sidebar:enter(
		sidebarConfig,
		not isCrankDocked,
		isCrankDocked and AVATAR_ID_NIL or 1
	)
	self.title:enter(not isCrankDocked)
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
	self.sidebar:updateData(not playdate.isCrankDocked(), self.player)
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
