class("SelectCreatorScreen").extends(Screen)

function SelectCreatorScreen:init()
	SelectCreatorScreen.super.init(self)

	self.collection = Collection()
end

function SelectCreatorScreen:enter(context)
	self.collection:enter(context)
end

function SelectCreatorScreen:leave()
	self.collection:leave()
end

function SelectCreatorScreen:setInvertedMode(active)
	self.collection:setInvertedMode(active)
end

function SelectCreatorScreen:setCreator(creator)
	self.collection:setCreator(creator)
end
