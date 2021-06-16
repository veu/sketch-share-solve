local gfx <const> = playdate.graphics

class("CreatorSelection").extends(Screen)

function CreatorSelection:init()
	CreatorSelection.super.init(self)

	self.sidebar = Sidebar()
	self.title = Title()
end

function CreatorSelection:enter(context)
	self.player = context.player
	local sidebarConfig = {
		topText = "Which level set?",
		menuItems = {}
	}

	self.creator = nil
	for creator, value in pairs(context.save.levels) do
		if not self.creator then
			self.creator = creator
		end
		table.insert(sidebarConfig.menuItems, {
			text = AVATAR_NAMES[creator]
		})
	end

	local isCrankDocked = playdate.isCrankDocked()
	self.sidebar:enter(sidebarConfig, not isCrankDocked, self.player, self.creator)

	self.sidebar.onNavigated = function (index)
		local i = 1
		for creator, value in pairs(context.save.levels) do
			if i == index then
				self.creator = creator
				break
			end
			i += 1
		end
		self.sidebar:updateData(not playdate.isCrankDocked(), self.player, self.creator)
		self.creator = self.creator
	end

	self.sidebar.onSelected = function ()
		self.onSelected(self.creator)
	end

	self.title:enter(not isCrankDocked)
end

function CreatorSelection:leave()
	self.sidebar:leave()
	self.title:leave()
end

function CreatorSelection:crankDocked()
	self.sidebar:close()
	self.title:setSidebarOpened(false)
end

function CreatorSelection:crankUndocked()
	self.sidebar:updateData(not playdate.isCrankDocked(), self.player, self.creator)
	self.sidebar:open()
	self.title:setSidebarOpened(true)
end

function CreatorSelection:cranked(change, acceleratedChange)
	self.sidebar:cranked(change, acceleratedChange)
end

function CreatorSelection:AButtonDown()
	self.sidebar:AButtonDown()
end

function CreatorSelection:BButtonDown()
	self.onBackToModeSelection()
end

function CreatorSelection:update()
end
