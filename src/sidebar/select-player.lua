class("SelectPlayerSidebar").extends(Sidebar)

function SelectPlayerSidebar:init()
	SelectPlayerSidebar.super.init(self)

	self.onNewPlayer = function () end
end

function SelectPlayerSidebar:enter(context)
	local config = {
		menuItems = {},
		menuTitle = "Who is playing?"
	}
	for _, id in pairs(context.save.profileList) do
		local profile = context.save.profiles[id]
		if not profile.hidden then
			if not self.player then
				self.player = profile
			end
			table.insert(config.menuItems, {
				text = profile.name,
				ref = profile
			})
		end
	end

	table.insert(config.menuItems, {
		text = "New player",
		exec = function()
			self.onNewPlayer()
		end
	})

	SelectPlayerSidebar.super.enter(self, config, not playdate.isCrankDocked(),
		not playdate.isCrankDocked() and 1 or nil)
end

function SelectPlayerSidebar:onNavigated_(player)
	self.player = player
	local avatar = player and player.avatar or AVATAR_ID_NIL
	self:setPlayer(avatar)
end

function SelectPlayerSidebar:open()
	SelectPlayerSidebar.super.open(self)
	self:onNavigated_(self.menuItems[self.cursor].ref)
end
