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
		text = "Before we start, if this text box is in the way, hold ⓑ to hide it and see all numbers.",
		grid = "000000000000000000011111100000000010000010000000010000010000000011111100000000010000010000000010000010000000010000010000000011111100000000000000000000",
	},
	{
		text = "Whatever you draw, your puzzle can only have one solution or players have to guess.",
		grid = "000000000000000000000111000000000001000100000000000000100000000000000100000000000001000000000000010000000000000000000000000000010000000000000000000000",
	},
	{
		text = "Take this puzzle for example. It has exactly two solutions that match the numbers.",
		grid = "000000000000000000000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
		solution = "222222222222222222222222222222222222102222222222222012222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222",
		hints = HINTS_ID_BLOCKS,
	},
	{
		text = "Players won’t know which is correct so they have to guess to finish the puzzle.",
		grid = "000000000000000000000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
		solution = "222222222222222222222222222222222222012222222222222102222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222",
		hints = HINTS_ID_BLOCKS,
	},
	{
		text = "There’s no automated check so you have to solve your newly created puzzle once.",
		grid = "000000000000000000000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
		solution = "222222222222222222222222222222222222002222222222222002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222",
		hints = HINTS_ID_BLOCKS,
	},
	{
		text = "If you find out that it can’t be solved, you can go back to change it and try again.",
		grid = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	},
	{
		text = "Let’s have a look at what makes puzzles (more likely to be) solvable.",
		grid = "000011100000000000100010000000001000001000000001000001000000001000001000000000100010000000000011101000000000000000100000000000000010000000000000001000",
	},
	{
		text = "There are some patterns that make any puzzle unsolvable, like thin diagonal lines.",
		grid = "000000000000000000010000010000000001000100000000000101000000000000010000000000000101000000000001000100000000010000010000000000000000000000000000000000",
	},
	{
		text = "Their unconnected blocks can move around without changing the numbers of the puzzle.",
		grid = "000000000000000000010000010000000001001000000000000100100000000000010000000000000100010000000010000100000000001001000000000000000000000000000000000000",
	},
	{
		text = "Possible fixes are: 1) drawing thicker lines which connect the blocks on both axes.",
		grid = "000000000000000000110000011000000011000110000000001101100000000000111000000000001101100000000011000110000000110000011000000000000000000000000000000000",
	},
	{
		text = "2) Boxing thin lines in between solid connected areas.",
		grid = "000000000000000001010000010100001101000101100001110101011100001111010111100001110101011100001101000101100001010000010100000000000000000000000000000000",
	},
	{
		text = "3) Inverting colors so the thin lines become the gaps between connected blocks.",
		grid = "000111111111000000101111101000000110111011000000111010111000000111101111000000111010111000000110111011000000101111101000000111111111000000000000000000",
	},
	{
		text = "All three approaches have in common that they add more black squares to the puzzle.",
		grid = "000010010111111000000101101111000001010111111000000101011111000010010111111000000101101111000001010111111000000101011111000010010111111000000101101111",
	},
	{
		text = "Rule of thumb: a puzzle with more black squares is more likely to be solvable.",
		grid = "000010010111111000000101101111000001010111111000000101011111000010010111111000000101101111000001010111111000000101011111000010010111111000000101101111",
	},
	{
		text = "A more complex example: this lion has a lot of thin lines and thus movable squares.",
		grid = "000010111110100000100000000010000100100010010000010000000100000010011100100000010011100100000010001000100000010110110100000001000001000000000111110000",
	},
	{
		text = "But after a quick gender swap our lion has more connected blocks and it's solvable.",
		grid = "000110111110100001100000000010011100100010010011110000000110011110011100110011110011100110011110001000110011110110110110001111000001100000011111111000",
		solution = "000110111110100001100000000010011100100010010011110000000110011110011100110011110011100110011110001000110011110110110110001111000001100000011111111000",
	},
	{
		text = "The game gives you tools for drawing including moving the puzzle by holding ⓑ.",
		grid = "000000000000000000011111100000000010000010000000010000010000000011111100000000010000010000000010000010000000010000010000000011111100000000000000000000",
	},
	{
		text = "But the most important tool is your creativity so go try it out! ☺",
		grid = "000000111000000000001000100000000010010010000000010101010000000010101010000000010010010000000001010100000000001010100000000000111000000000000111000000",
	},
}

function SketchTutorialScreen:enter(context)
	self.page = 1
	self.hintStyle = context.settings.hintStyle
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
	self.grid:enter(self.puzzle, MODE_TUTORIAL, page.hints or HINTS_ID_OFF, self.hintStyle, false, solution)
	self.grid:hideCursor()
	self.dialog:enter(page.text)
	self.dialog:setVisible(true)
	self.frame = -19
	self.cantIdle = page.steps
end

function SketchTutorialScreen:updateHintStyle(context)
	self.hintStyle = context.settings.hintStyle
	self.grid:updateHintStyle(self.hintStyle)
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
