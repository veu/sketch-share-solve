class("SelectAvatarSidebar").extends(Sidebar)

function SelectAvatarSidebar:init()
	SelectAvatarSidebar.super.init(self)

	self.onNewPlayer = function () end
end

function SelectAvatarSidebar:enter(context, selected)
	local config = {
		player = imgAvatars:getImage(1),
		menuItems = {},
		menuTitle = "Choose an avatar"
	}
	for i = 1, NUM_AVATARS do
		table.insert(config.menuItems, {
			text = AVATAR_NAMES[i],
			avatar = imgAvatars:getImage(i),
			ref = i
		})
	end

	table.insert(config.menuItems, {
		text = "Create new avatar",
		selected = selected == AVATAR_ID_CREATE_AVATAR,
		avatar = imgAvatars:getImage(AVATAR_ID_NIL),
		exec = function()
			self.onNewAvatar()
		end
	})

	SelectAvatarSidebar.super.enter(self, context, config)
end

function SelectAvatarSidebar:onCranked()
	self.playerAvatar:change(self.cursorRaw)
end

function SelectAvatarSidebar:onMoved()
	self.playerAvatar:setTarget(self.cursorRaw)
end
