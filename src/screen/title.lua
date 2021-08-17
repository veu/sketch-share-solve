local gfx <const> = playdate.graphics

class("TitleScreen").extends(Screen)

function TitleScreen:init()
	TitleScreen.super.init(self)

	self.title = Title()
	self.creator = Creator()
end

function TitleScreen:enter(context)
	self.title:enter(context)
	self.creator:enter()
end

function TitleScreen:leave()
	self.title:leave()
	self.creator:leave()
end

function TitleScreen:sidebarClosed()
	self.title:sidebarClosed()
end

function TitleScreen:sidebarOpened()
	self.title:sidebarOpened()
end
