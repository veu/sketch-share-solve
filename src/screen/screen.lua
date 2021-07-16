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
end

function Screen:BButtonDown()
end

function Screen:crankDocked()
end

function Screen:crankUndocked()
end

function Screen:update()
end

function Screen:handleCursorDir(button, update)
	if playdate.buttonJustPressed(button) then
		self.pressCounter = 0
		update()
		if playdate.buttonIsPressed(playdate.kButtonA) then
			self:fill(false)
		elseif playdate.buttonIsPressed(playdate.kButtonB) then
			self:cross(false)
		end
	elseif playdate.buttonIsPressed(button) then
		self.pressCounter += 1
		if self.pressCounter > 4 and self.pressCounter % 4 == 0 then
			update()
			if playdate.buttonIsPressed(playdate.kButtonA) then
				self:fill(false)
			elseif playdate.buttonIsPressed(playdate.kButtonB) then
				self:cross(false)
			end
		end
	elseif playdate.buttonJustReleased(button) then
		self.pressCounter = 0
	end
end
