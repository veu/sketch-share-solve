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

function Screen:updateHintStyle(context)
end

function Screen:startUndo()
	self.cursor = 0
	self.cursorRaw = 0
	self.timer:startUndo()
end

function Screen:endUndo()
	self.grid:goBackTo(self.cursor)
	self.timer:endUndo()
end

function Screen:undoCranked(change, acceleratedChange)
	self.cursorRaw = math.max(0, math.min(self.grid:getHistorySize(), (self.cursorRaw - acceleratedChange / 20)))
	local newCursor = math.floor(self.cursorRaw + 0.5)
	if self.cursor ~= newCursor then
		self.cursor = newCursor
		self.grid:lookBackTo(self.cursor)
		playEffect("scroll")
	end
end
