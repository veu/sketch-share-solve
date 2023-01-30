class("SelectPuzzleScreen").extends(Screen)

function SelectPuzzleScreen:init()
	SelectPuzzleScreen.super.init(self)

	self.preview = PuzzlePreview()
end

function SelectPuzzleScreen:enter(context)
	self.preview:enter(context)
end

function SelectPuzzleScreen:leave()
	self.preview:leave()
end

function SelectPuzzleScreen:setPuzzle(puzzle, preview)
	self.preview:setPuzzle(puzzle, preview)
end
