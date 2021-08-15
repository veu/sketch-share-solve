local gfx <const> = playdate.graphics

class("TitleScreen").extends(Screen)

function TitleScreen:init()
	TitleScreen.super.init(self)

	self.title = Title()
end

function TitleScreen:enter(context)
	self.title:enter(context)
end

function TitleScreen:leave()
	self.title:leave()
end

function TitleScreen:sidebarClosed()
	self.title:sidebarClosed()
end

function TitleScreen:sidebarOpened()
	self.title:sidebarOpened()
end
