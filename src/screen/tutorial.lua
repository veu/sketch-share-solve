class("TutorialScreen").extends(Screen)

function TutorialScreen:init()
	TutorialScreen.super.init(self)

	self.grid = Grid(true)
	self.dialog = TutorialDialog()
end

local TUTORIAL = {
	{
		text = "This is step 1",
		grid = "000110111110100001100000000010011100100010010011110000000110011110011100110011110011100110011110001000110011110110110110001111000001100000011111111000",
		solution = "000110111110100001100000000010011100100010010011110000000110011110011100110011110011100110011110001000110011110110110110001111000001100000011111111000"
	},
	{
		text = "This is step 2",
		grid = "000110111110100001100000000010011100100010010011110000000110011110011100110011110011100110011110001000110011110110110110001111000001100000011111111000",
		solution = "000110111110100001100000000010011100100010010011110000000110011110011100110011110011100110011110001000110011110110110110001111000001100000011111111000"
	}
}

function TutorialScreen:enter(context)
	self.step = 1
	self:loadStep()
end

function TutorialScreen:leave()
	self.grid:leave()
	self.dialog:leave()
end

function TutorialScreen:loadStep()
	 self.puzzle = Puzzle({
		 width = 15,
		 height = 10,
		 grid = TUTORIAL[self.step].grid
	})
	local solution = nil
	if TUTORIAL[self.step].solution then
		solution = table.create(150, 0)
		local values = {string.byte(TUTORIAL[self.step].solution, 1, 150)}
		for i = 1, 150 do
			solution[i] = values[i] - 48
		end
	end
	self.grid:enter(self.puzzle, MODE_TUTORIAL, HINTS_ID_OFF, solution)
	self.grid:hideCursor()
	self.dialog:enter(TUTORIAL[self.step].text)
end

function TutorialScreen:AButtonDown()
	if self.step < #TUTORIAL then
		self.step += 1
		self:loadStep()
	end
end

function TutorialScreen:BButtonDown()
	self.dialog:setVisible(false)
end

function TutorialScreen:BButtonUp()
	self.dialog:setVisible(true)
end
