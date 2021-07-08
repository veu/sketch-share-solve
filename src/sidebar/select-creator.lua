class("SelectCreatorSidebar").extends(Sidebar)

function SelectCreatorSidebar:init()
	SelectCreatorSidebar.super.init(self)
end

function SelectCreatorSidebar:enter(context, selected)
	local config = {
		player = context.player.avatar,
		menuItems = {},
		menuTitle = "Choose a creator"
	}

	local selectedIndex = nil
	local i = 1
	local creator = nil
	for _, id in pairs(context.save.profileList) do
		local profile = Player.load(context, id)
		if #profile.created > 0 then
			if profile.id == selected or not creator then
				selectedIndex = i
				creator = profile
			end
			table.insert(config.menuItems, {
				text = profile.name,
				avatar = profile.avatar,
				ref = profile,
				selected = profile.id == selected,
				checked = context.player:playedAllBy(profile),
			})
			i += 1
		end
	end

	config.creator = creator.avatar

	SelectCreatorSidebar.super.enter(self, context, config)
end

function SelectCreatorSidebar:onCranked()
	self.creatorAvatar:change(self.cursorRaw)
end

function SelectCreatorSidebar:onMoved()
	self.creatorAvatar:setTarget(self.cursorRaw)
end
