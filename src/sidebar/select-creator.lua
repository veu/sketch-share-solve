class("SelectCreatorSidebar").extends(Sidebar)

function SelectCreatorSidebar:init()
	SelectCreatorSidebar.super.init(self)
end

function SelectCreatorSidebar:enter(context)
	local config = {
		menuItems = {},
		menuTitle = "Choose creator"
	}

	local creator = nil
	for _, id in pairs(context.save.profileList) do
		local profile = Player(context.save.profiles[id])
		if #profile.created > 0 then
			if not creator then
				creator = profile
			end
			table.insert(config.menuItems, {
				text = profile.name,
				ref = profile
			})
		end
	end

	SelectCreatorSidebar.super.enter(
		self,
		config,
		not playdate.isCrankDocked(),
		context.player.avatar,
		creator.avatar
	)
end

function SelectCreatorSidebar:onNavigated_(creator)
	self:setCreator(creator.avatar)
end
