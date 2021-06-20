class("Screen").extends()

function Screen:init()
	Screen.super.init(self)

	self.sidebar = Sidebar()
end

function Screen:enter()
end

function Screen:leave()
end

function Screen:invertBoard()
end

function Screen:AButtonDown()
	self.sidebar:AButtonDown()
end

function Screen:BButtonDown()
	self.sidebar:BButtonDown()
end

function Screen:update()
end
