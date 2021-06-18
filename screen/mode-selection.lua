local gfx <const> = playdate.graphics

class("ModeSelection").extends(Screen)

function ModeSelection:init()
	ModeSelection.super.init(self)
	self.player = nil
	self.mode = nil

	self.title = Title()
end

function ModeSelection:enter(context)
	self.mode = 1
	local sidebarConfig = {
		menuItems = {
			{ text = "Play" },
			{ text = "Create" },
		}
	}
	self.sidebar:enter(sidebarConfig, not playdate.isCrankDocked(), context.player)

	self.sidebar.onAbort = function ()
		self.onBackToTitle()
	end
	self.sidebar.onNavigated = function (index)
		self.mode = index
	end
	self.sidebar.onSelected = function ()
		self.onSelected(self.mode)
	end

	self.title:enter()
end

function ModeSelection:leave()
	self.sidebar:leave()
	self.title:leave()
end

function ModeSelection:crankDocked()
	self.sidebar:close()
end

function ModeSelection:crankUndocked()
	self.sidebar:open()
end

function ModeSelection:update()
end
