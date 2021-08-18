class("SelectTutorial").extends(Sidebar)

function SelectTutorial:init()
	SelectTutorial.super.init(self)
end

function SelectTutorial:enter(context, selected)
	local config = {
		menuTitle = "Choose a tutorial",
		menuItems = {
			{
				text = "Solve tutorial",
				disabled = true,
				disabledText = "Under Construction..."
			},
			{
				text = "Sketch tutorial",
				disabled = true,
				disabledText = "Under Construction..."
			},
		}
	}

	SelectTutorial.super.enter(
		self,
		context,
		config
	)
end
