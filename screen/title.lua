local gfx <const> = playdate.graphics

class("TitleScreen").extends(Screen)

function TitleScreen:init()
	TitleScreen.super.init(self)

	self.title = Title()
end

function TitleScreen:enter(context)
	self.player = nil
	self.save = context.save
	local sidebarConfig = {
		menuItems = {},
		menuTitle = "Who is playing?"
	}
	for _, id in pairs(context.save.profileList) do
		local profile = context.save.profiles[id]
		if not profile.hidden then
			if not self.player then
				self.player = profile
			end
			table.insert(sidebarConfig.menuItems, {
				text = profile.name,
				ref = profile
			})
		end
	end

	local isCrankDocked = playdate.isCrankDocked()
	self.sidebar:enter(
		sidebarConfig,
		not isCrankDocked,
		not isCrankDocked and 1 or nil
	)

	self.sidebar.onNavigated = function (player)
		self.player = player
		self.sidebar:setPlayer(player.avatar)
	end
	self.sidebar.onSelected = function (id)
		self.onSelected(id)
	end

	self.title:enter()
end

function TitleScreen:leave()
	self.sidebar:leave()
	self.title:leave()
end

function TitleScreen:crankUndocked()
	self.sidebar:setPlayer(self.player.avatar)
	self.sidebar:open()
end
