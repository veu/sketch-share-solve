class("AboutScreen").extends(Screen)

function AboutScreen:init()
	AboutScreen.super.init(self)

	self.about = About()
end

function AboutScreen:enter(context)
	self.about:enter(context)
end

function AboutScreen:leave()
	self.about:leave()
end

function AboutScreen:sidebarClosed()
	self.about:sidebarClosed()
end

function AboutScreen:sidebarOpened()
	self.about:sidebarOpened()
end
