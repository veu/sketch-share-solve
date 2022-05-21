class("SelectPuzzleScreen").extends(Screen)

function SelectPuzzleScreen:init()
	SelectPuzzleScreen.super.init(self)

	self.collection = Collection()
end

function SelectPuzzleScreen:enter(context)
	self.collection:enter(context)
end

function SelectPuzzleScreen:leave()
	self.collection:leave()
end
