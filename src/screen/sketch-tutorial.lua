class("SketchTutorialScreen").extends(Screen)

function SketchTutorialScreen:init()
	SketchTutorialScreen.super.init(self)

	self.grid = Grid(true)
	self.dialog = TutorialDialog()
end

local TUTORIAL = {
	{
		text = "Hello again! This tutorial will teach you how to make your own nonogram puzzles.",
		grid = "000000000000000001000100000100001000100100100001000100000100001111100100100001000100100100001000100100100001000100100000001000100100100000000000000000",
	},
	{
		text = "Before we start, if this text box is in the way, hold *(b)* to hide it and see all numbers.",
		grid = "000000000000000000011111100000000010000010000000010000010000000011111100000000010000010000000010000010000000010000010000000011111100000000000000000000",
	},
	{
		text = "Good news first: creating nonograms means solving a lot of nonograms. Wait, what?",
		grid = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	},
	{
		text = "Whatever you draw, your puzzle can only have one solution or players have to guess.",
		grid = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	},
	{
		text = "Take this puzzle for example. It has exactly two solutions that match the numbers.",
		grid = "000000000000000000000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
		solution = "222222222222222222222222222222222222102222222222222012222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222",
		hints = HINTS_ID_BLOCKS,
	},
	{
		text = "Players won’t know which one is the right one so they have to guess to finish it.",
		grid = "000000000000000000000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
		solution = "222222222222222222222222222222222222012222222222222102222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222",
		hints = HINTS_ID_BLOCKS,
	},
	{
		text = "There’s no automated check after creating a puzzle so you’ll be asked to solve it.",
		grid = "000000000000000000000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	},
	{
		text = "If you realize that it can’t be solved, you can go back to change it and try again.",
		grid = "000000000000000000000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	},
	{
		text = "Let’s have a look at what makes puzzles (more likely to be) solvable.",
		grid = "000000000000000000000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	},
	{
		text = "Rule of thumb: the more black squares you have, the more likely it’ll be solvable.",
		grid = "000000000000000000000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	},
	{
		text = "There are some patterns that are never solvable like diagonal lines.",
		grid = "000000000000000000000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	},
	{
		text = "The reason is that individual blocks are not connected and can move around freely.",
		grid = "000000000000000000000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	},
	{
		text = "The quickest fix is to draw a thicker line which connects the blocks on both axes.",
		grid = "000000000000000000000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	},
	{
		text = "A more complex example: this lion has a lot of thin lines an thus movable squares.",
		grid = "000010111110100000100000000010000100100010010000010000000100000010011100100000010011100100000010001000100000010110110100000001000001000000000111110000",
	},
	{
		text = "But after a quick gender swap the lion has more connections and is solvable again.",
		grid = "000110111110100001100000000010011100100010010011110000000110011110011100110011110011100110011110001000110011110110110110001111000001100000011111111000",
		solution = "000110111110100001100000000010011100100010010011110000000110011110011100110011110011100110011110001000110011110110110110001111000001100000011111111000",
	},
	-- TODO: more tools for players
}

function SketchTutorialScreen:enter(context)
	self.page = 3
	self:loadPage()
end

function SketchTutorialScreen:leave()
	self.grid:leave()
	self.dialog:leave()
end

function SketchTutorialScreen:loadPage()
	local page = TUTORIAL[self.page]
	 self.puzzle = Puzzle({
		 width = 15,
		 height = 10,
		 grid = page.grid or GRID_EMPTY
	})
	local solution = nil
	local pageSolution = page.solution or page.grid
	if pageSolution then
		solution = table.create(150, 0)
		local values = {string.byte(pageSolution, 1, 150)}
		for i = 1, 150 do
			solution[i] = values[i] - 48
		end
	end
	self.grid:enter(self.puzzle, MODE_TUTORIAL, page.hints or HINTS_ID_OFF, solution)
	self.grid:hideCursor()
	self.dialog:enter(page.text)
	self.frame = -19
	self.cantIdle = page.steps
end

function SketchTutorialScreen:AButtonDown()
	if self.page < #TUTORIAL then
		self.page += 1
		self:loadPage()
	else
		openSidebar()
	end
end

function SketchTutorialScreen:BButtonDown()
	self.dialog:setVisible(false)
end

function SketchTutorialScreen:BButtonUp()
	self.dialog:setVisible(true)
end

function SketchTutorialScreen:leftButtonDown(pressed)
	if self.page > 1 then
		self.page -= 1
		self:loadPage()
	end
end

function SketchTutorialScreen:rightButtonDown(pressed)
	if self.page < #TUTORIAL then
		self.page += 1
		self:loadPage()
	end
end

function SketchTutorialScreen:update()
	if self.frame then
		if self.frame % 20 == 0 then
			local page = TUTORIAL[self.page]
			if page.steps then
				local step = math.floor(self.frame / 20)
				page.update(self, step % page.steps + 1)
			end
		end
		self.frame += 1
	end
end
