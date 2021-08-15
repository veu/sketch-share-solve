function createDefaultInputHandler(context)
	local buttons = {
		playdate.kButtonRight,
		playdate.kButtonDown,
		playdate.kButtonLeft,
		playdate.kButtonUp
	}
	local pressed = table.create(#buttons, 0)

	return {
		crankDocked = function ()
			resume()
			closeSidebar()
		end,

		crankUndocked = function ()
			resume()
			openSidebar()
		end,

		cranked = function (change, acceleratedChange)
			resume()
			if context.isSidebarOpen then
				local factor = 0.5 + context.settings.crankSpeed * 0.1
				context.sidebar:cranked(-change * factor, -acceleratedChange * factor)
			end
		end,

		downButtonDown = function ()
			resume()
			if context.isSidebarOpen then
				context.sidebar:downButtonDown()
			else
				context.screen:downButtonDown()
			end
		end,

		leftButtonDown = function ()
			resume()
			if context.isSidebarOpen then
				context.sidebar:leftButtonDown()
			else
				context.screen:leftButtonDown()
			end
		end,

		rightButtonDown = function ()
			resume()
			if context.isSidebarOpen then
				context.sidebar:rightButtonDown()
			else
				context.screen:rightButtonDown()
			end
		end,

		upButtonDown = function ()
			resume()
			if context.isSidebarOpen then
				context.sidebar:upButtonDown()
			else
				context.screen:upButtonDown()
			end
		end,

		AButtonDown = function ()
			resume()
			if context.isSidebarOpen then
				context.sidebar:AButtonDown()
			else
				context.screen:AButtonDown()
			end
		end,

		BButtonDown = function ()
			resume()
			if context.isSidebarOpen then
				context.sidebar:BButtonDown()
			else
				context.screen:BButtonDown()
			end
		end,

		BButtonUp = function ()
			resume()
			if not context.isSidebarOpen then
				context.screen:BButtonUp()
			end
		end,

		update = function ()
			for i, button in ipairs(buttons) do
				if playdate.buttonJustPressed(button) then
					pressed[i] = 0
				elseif playdate.buttonIsPressed(button) then
					pressed[i] = pressed[i] and pressed[i] + 1 or 0
					if pressed[i] > 5 and pressed[i] % 5 == 0 then
						if context.isSidebarOpen then
							context.sidebar:buttonPressed(button)
						else
							context.screen:buttonPressed(button)
						end
					end
				end
			end
		end
	}
end
