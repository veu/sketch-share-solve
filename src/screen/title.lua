local gfx <const> = playdate.graphics

class("TitleScreen").extends(Screen)

function TitleScreen:init()
	TitleScreen.super.init(self)

	self.showCrank = true

	self.title = Title()
end

function TitleScreen:enter(context)
	self.title:enter(context)
end

function TitleScreen:leave()
	self.title:leave()
end

function TitleScreen:crankDocked()
	self.title:crankDocked()
end

function TitleScreen:crankUndocked()
	self.title:crankUndocked()
end
