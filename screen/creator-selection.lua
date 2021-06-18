local gfx <const> = playdate.graphics

class("CreatorSelection").extends(Screen)

function CreatorSelection:init()
	CreatorSelection.super.init(self)

	self.title = Title()
end

function CreatorSelection:enter(context)
	local sidebarConfig = {
		menuItems = {},
		menuTitle = "Choose creator"
	}

	local creator = nil
	for _, id in pairs(context.save.profileList) do
		local profile = context.save.profiles[id]
		if #profile.created > 0 then
			if not creator then
				creator = profile
			end
			table.insert(sidebarConfig.menuItems, {
				text = profile.name,
				ref = profile
			})
		end
	end

	local isCrankDocked = playdate.isCrankDocked()
	self.sidebar:enter(sidebarConfig, not isCrankDocked, context.player.avatar, creator.avatar)

	self.sidebar.onAbort = function ()
		self.onBackToModeSelection()
	end

	self.sidebar.onNavigated = function (creator)
		self.sidebar:setCreator(creator.avatar)
	end

	self.sidebar.onSelected = function (creator)
		self.onSelected(creator)
	end

	self.title:enter()
end

function CreatorSelection:leave()
	self.sidebar:leave()
	self.title:leave()
end
