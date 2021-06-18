local gfx <const> = playdate.graphics

class("ModeSelection").extends(Screen)

function ModeSelection:init()
	ModeSelection.super.init(self)

	self.title = Title()
end

function ModeSelection:enter(context)
	local sidebarConfig = {
		menuItems = {
			{ text = "Play", ref = MODE_PLAY },
			{ text = "Create", ref = MODE_CREATE },
		}
	}
	self.sidebar:enter(sidebarConfig, not playdate.isCrankDocked(), context.player.avatar)

	self.sidebar.onAbort = function ()
		self.onBackToTitle()
	end
	self.sidebar.onSelected = function (mode)
		self.onSelected(mode)
	end

	self.title:enter()
end

function ModeSelection:leave()
	self.sidebar:leave()
	self.title:leave()
end
