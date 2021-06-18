local gfx <const> = playdate.graphics

class("TitleScreen").extends(Screen)

function TitleScreen:init()
	TitleScreen.super.init(self)

	self.title = Title()
end

function TitleScreen:enter()
	self.player = 1
	local sidebarConfig = {
		menuItems = {
			{ text = "Suave Snail" },
			{ text = "Charming Cat" },
			{ text = "Mindful Mouse" },
			{ text = "Reliable Raccoon"}
		},
		menuTitle = "Who is playing?"
	}
	local isCrankDocked = playdate.isCrankDocked()
	self.sidebar:enter(
		sidebarConfig,
		not isCrankDocked,
		not isCrankDocked and 1 or nil
	)

	self.sidebar.onNavigated = function (index)
		self.sidebar:updateData(not playdate.isCrankDocked(), index)
		self.player = index
	end
	self.sidebar.onSelected = function ()
		self.onSelected(self.player)
	end

	self.title:enter()
end

function TitleScreen:leave()
	self.sidebar:leave()
	self.title:leave()
end

function TitleScreen:crankUndocked()
	self.sidebar:updateData(not playdate.isCrankDocked(), self.player)
	self.sidebar:open()
end
