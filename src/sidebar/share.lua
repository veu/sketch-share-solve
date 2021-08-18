class("ShareSidebar").extends(Sidebar)

function ShareSidebar:init()
	ShareSidebar.super.init(self)
end

function ShareSidebar:enter(context, selected)
	local config = {
		player = context.player.avatar,
		menuTitle = "Share",
		menuItems = {
			{
				text = "Export puzzles",
				disabled = #context.player.created == 0,
				disabledText = "You haven’t created any puzzles yet.",
				exec = function ()
					self.onExportPuzzles()
				end
			},
		}
	}

	ShareSidebar.super.enter(
		self,
		context,
		config
	)
end
