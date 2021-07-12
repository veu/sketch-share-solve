class("SelectPlayerSidebar").extends(Sidebar)

function SelectPlayerSidebar:init()
	SelectPlayerSidebar.super.init(self)

	self.onNewPlayer = function () end
end

function SelectPlayerSidebar:enter(context, selected)
	local isNaming = selected == PLAYER_ID_SHOW_NAME or selected == PLAYER_ID_SHOW_RENAME
	local config = {
		menuItems = {},
		menuTitle = isNaming and "Choose a name" or "Who is playing?",
		stayOpen = isNaming
	}

	local selectedIndex = 1
	local i = 1
	for _, id in pairs(context.save.profileList) do
		local profile = Player.load(context, id)
		if not profile.hidden then
			if profile.id == selected then
				selectedIndex = i
			end
			local isRenamedPlayer =
				selected == PLAYER_ID_SHOW_RENAME and profile.id == context.player.id
			table.insert(config.menuItems, {
				text = isRenamedPlayer and context.player.name or profile.name,
				avatar = profile.avatar,
				ref = profile,
				selected = profile.id == selected or isRenamedPlayer,
				showCursor = isRenamedPlayer,
			})
			i += 1
		end
	end

	if selected == PLAYER_ID_SHOW_NAME then
		table.insert(config.menuItems, {
			text = context.player.name,
			avatar = context.player.avatar,
			selected = true,
			showCursor = true,
		})
		selectedIndex = #config.menuItems
	else
		table.insert(config.menuItems, {
			text = "New player",
			avatar = imgAvatars:getImage(AVATAR_ID_NIL),
			exec = function()
				self.onNewPlayer()
			end
		})
	end

	if not context.isCrankDocked then
		config.player = config.menuItems[selectedIndex].avatar
	end

	SelectPlayerSidebar.super.enter(self, context, config)
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
end
