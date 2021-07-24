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
			context.isCrankDocked = true
			context.screen:crankDocked()
			context.sidebar:close()
		end,

		crankUndocked = function ()
			resume()
			context.isCrankDocked = false
			context.screen:crankUndocked()
			context.sidebar:open()
		end,

		cranked = function (change, acceleratedChange)
			resume()
			local factor = 0.5 + context.settings.crankSpeed * 0.1
			context.sidebar:cranked(-change * factor, -acceleratedChange * factor)
		end,

		downButtonDown = function ()
			resume()
			if playdate.isCrankDocked() then
				context.screen:downButtonDown()
			else
				context.sidebar:downButtonDown()
			end
		end,

		leftButtonDown = function ()
			resume()
			if playdate.isCrankDocked() then
				context.screen:leftButtonDown()
			else
				context.sidebar:leftButtonDown()
			end
		end,

		rightButtonDown = function ()
			resume()
			if playdate.isCrankDocked() then
				context.screen:rightButtonDown()
			else
				context.sidebar:rightButtonDown()
			end
		end,

		upButtonDown = function ()
			resume()
			if playdate.isCrankDocked() then
				context.screen:upButtonDown()
			else
				context.sidebar:upButtonDown()
			end
		end,

		AButtonDown = function ()
			resume()
			if playdate.isCrankDocked() then
				context.screen:AButtonDown()
			else
				context.sidebar:AButtonDown()
			end
		end,

		BButtonDown = function ()
			resume()
			if playdate.isCrankDocked() then
				context.screen:BButtonDown()
			else
				context.sidebar:BButtonDown()
			end
		end,

		update = function ()
			for i, button in ipairs(buttons) do
				if playdate.buttonJustPressed(button) then
					pressed[i] = 0
				elseif playdate.buttonIsPressed(button) then
					pressed[i] += 1
					if pressed[i] > 5 and pressed[i] % 5 == 0 then
						if playdate.isCrankDocked() then
							context.screen:buttonPressed(button)
						else
							context.sidebar:buttonPressed(button)
						end
					end
				end
			end
		end
	}
end
