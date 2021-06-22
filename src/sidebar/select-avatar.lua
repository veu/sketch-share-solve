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

	table.insert(config.menuItems, {
		text = "New avatar",
		exec = function()
			self.onNewAvatar()
		end
	})

	SelectAvatarSidebar.super.enter(
		self,
		config,
		not playdate.isCrankDocked(),
		imgAvatars:getImage(1)
	)
end

function SelectAvatarSidebar:onNavigated_(avatar)
	self:setPlayer(imgAvatars:getImage(avatar or AVATAR_ID_NIL))
end
