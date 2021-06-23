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
			avatar = imgAvatars:getImage(i),
			ref = i
		})
	end

	table.insert(config.menuItems, {
		text = "New avatar",
		avatar = imgAvatars:getImage(AVATAR_ID_NIL),
		exec = function()
			self.onNewAvatar()
		end
	})

	SelectAvatarSidebar.super.enter(
		self,
		config,
		imgAvatars:getImage(1)
	)
end

function SelectAvatarSidebar:onCranked()
	self.playerAvatar:change(self.cursorRaw)
end
