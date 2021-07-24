function createModalInputHandler(context)
	return {
		AButtonDown = function ()
			resume()
			context.modal:AButtonDown()
		end,

		BButtonDown = function ()
			resume()
			context.modal:BButtonDown()
		end
	}
end
