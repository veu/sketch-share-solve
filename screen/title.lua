local gfx <const> = playdate.graphics

class("TitleScreen").extends(Screen)

function TitleScreen:init()
	TitleScreen.super.init(self)

	self.title = Title()
end

function TitleScreen:enter(context)
	self.title:enter()
end

function TitleScreen:leave()
	self.title:leave()
end
