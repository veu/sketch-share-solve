class("NamePlayerSidebar").extends(Sidebar)

function NamePlayerSidebar:init()
	NamePlayerSidebar.super.init(self)
end

function NamePlayerSidebar:enter(context)
	local config = {
		menuTitle = "Choose name",
		menuItems = {
			{
				text = context.player.name
			}
		}
	}

	NamePlayerSidebar.super.enter(
		self,
		config,
		true,
		context.player.avatar
	)
end

function NamePlayerSidebar:open()
	-- needs to stay open until keyboard is closed
end

function NamePlayerSidebar:close()
	-- needs to stay open until keyboard is closed
end
