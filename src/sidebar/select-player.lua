class("SelectPlayerSidebar").extends(Sidebar)

function SelectPlayerSidebar:init()
	SelectPlayerSidebar.super.init(self)

	self.onNewPlayer = function () end
end

function SelectPlayerSidebar:enter(context, selected)
	local config = {
		menuItems = {},
		menuTitle = "Who is playing?"
	}

	local selectedIndex = 1
	local i = 1
	for _, id in pairs(context.save.profileList) do
		local profile = Player.load(context, id)
		if not profile.hidden then
			if profile.id == selected then
				selectedIndex = i
			end
			table.insert(config.menuItems, {
				text = profile.name,
				avatar = profile.avatar,
				ref = profile,
				selected = profile.id == selected,
			})
			i += 1
		end
	end

	table.insert(config.menuItems, {
		text = "New player",
		avatar = imgAvatars:getImage(AVATAR_ID_NIL),
		exec = function()
			self.onNewPlayer()
		end
	})

	local avatar = config.menuItems[selectedIndex].avatar
	SelectPlayerSidebar.super.enter(
		self,
		config,
		not playdate.isCrankDocked() and avatar or nil
	)
end

function SelectPlayerSidebar:onCranked()
	self.playerAvatar:change(self.cursorRaw)
end

function SelectPlayerSidebar:onMoved()
	self.playerAvatar:setTarget(self.cursorRaw)
end

function SelectPlayerSidebar:onNavigated_()
	self:redraw()
end

function SelectPlayerSidebar:open()
	SelectPlayerSidebar.super.open(self)
	if not self.playerAvatar:isVisible() then
		self.playerAvatar:enter(self.config, self.menuItems[self.cursor].avatar)
	end

	self:redraw()
end
