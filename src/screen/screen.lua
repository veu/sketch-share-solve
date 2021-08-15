class("Screen").extends()

function Screen:init()
	Screen.super.init(self)
end

function Screen:enter()
end

function Screen:leave()
end

function Screen:invertGrid()
end

function Screen:resetGrid()
end

function Screen:AButtonDown()
	openSidebar()
end

function Screen:BButtonDown()
	openSidebar()
end

function Screen:BButtonUp()
end

function Screen:downButtonDown()
end

function Screen:leftButtonDown()
end

function Screen:rightButtonDown()
end

function Screen:upButtonDown()
end

function Screen:sidebarOpened()
end

function Screen:sidebarClosed()
end

function Screen:buttonPressed()
end

function Screen:update()
end
