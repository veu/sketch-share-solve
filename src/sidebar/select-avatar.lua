class("SelectAvatarSidebar").extends(Sidebar)

function SelectAvatarSidebar:init()
	SelectAvatarSidebar.super.init(self)

	self.onNewPlayer = function () end
end

function SelectAvatarSidebar:enter(context)
	local config = {
		menuItems = {},
		menuTitle = "Choose avatar"
	}
	for i = 1, NUM_AVATARS do
		table.insert(config.menuItems, {
			text = AVATAR_NAMES[i],
			ref = i
		})
	end

	SelectAvatarSidebar.super.enter(self, config, not playdate.isCrankDocked(), 1)
end

function SelectAvatarSidebar:onNavigated_(avatar)
	self:setPlayer(avatar)
end
