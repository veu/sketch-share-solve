function createUndoInputHandler(context)
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
			endUndo()
		end,

		crankUndocked = function ()
			resume()
		end,

		cranked = function (change, acceleratedChange)
			resume()
			local factor = 0.5 + context.settings.crankSpeed * 0.1
			context.screen:undoCranked(-change * factor, -acceleratedChange * factor)
		end,

		BButtonDown = function ()
			resume()
			endUndo()
		end,
	}
end
