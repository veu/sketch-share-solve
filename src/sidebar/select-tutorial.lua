class("SelectTutorialSidebar").extends(Sidebar)

function SelectTutorialSidebar:init()
	SelectTutorialSidebar.super.init(self)
end

function SelectTutorialSidebar:enter(context, selected)
	local config = {
		menuTitle = "Choose a tutorial",
		menuItems = {
			{
				text = "Solve tutorial",
				selected = selected == ACTION_ID_SOLVE_TUTORIAL,
				exec = function()
						self.onSolveTutorial()
				end
			},
			{
				text = "Sketch tutorial",
				selected = selected == ACTION_ID_SKETCH_TUTORIAL,
				exec = function()
						self.onSketchTutorial()
				end
			},
		}
	}

	SelectTutorialSidebar.super.enter(
		self,
		context,
		config
	)
end
