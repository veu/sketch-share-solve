class("Screen").extends()

function Screen:init()
	Screen.super.init(self)

	self.sidebar = Sidebar()
end

function Screen:enter()
end

function Screen:leave()
end

function Screen:crankDocked()
	self.sidebar:close()
end

function Screen:crankUndocked()
	self.sidebar:open()
end

function Screen:cranked(change, acceleratedChange)
	self.sidebar:cranked(change, acceleratedChange)
end

function Screen:AButtonDown()
	self.sidebar:AButtonDown()
end

function Screen:BButtonDown()
	self.sidebar:BButtonDown()
end

function Screen:update()
end
