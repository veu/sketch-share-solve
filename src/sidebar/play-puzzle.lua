class("PlayPuzzleSidebar").extends(Sidebar)

function PlayPuzzleSidebar:init()
	PlayPuzzleSidebar.super.init(self)
end

function PlayPuzzleSidebar:enter(context, selected)
	local player = context.player
	local creator = context.creator
	local puzzle = context.puzzle
	local config = {
		player = player.avatar,
		creator = creator.avatar,
		menuTitle = self:getTitle(player, creator, puzzle),
		menuItems = {
			{
				text = puzzle.hasBeenSolved and "See results" or "Solve",
				exec = function()
					closeSidebar()
				end
			}
		}
	}

	if not puzzle.hasBeenSolved then
		table.insert(config.menuItems, {
			text = "Undo",
			selected = selected == ACTION_ID_UNDO,
			exec = function ()
				self.onUndo()
			end
		})
		table.insert(config.menuItems, {
			text = "Hint style: " .. NUM_STYLE_NAMES[context.settings.hintStyle],
			selected = selected == ACTION_ID_HINT_STYLE,
			img = createHintStylePreview(context.settings.hintStyle),
			exec = function ()
				self.onHintStyleNext()
			end,
			execLeft = function ()
				self.onHintStylePrevious()
			end,
			execRight = function ()
				self.onHintStyleNext()
			end
		})
		local autocrossText = "Autocomplete: " .. (
			context.player.options.autoCross and "on" or "off"
		)
		table.insert(config.menuItems, {
			text = autocrossText,
			selected = selected == ACTION_ID_TOGGLE_AUTOCROSS,
			exec = function ()
				self.onToggleAutoCross()
			end,
			execLeft = function ()
				self.onToggleAutoCross()
			end,
			execRight = function ()
				self.onToggleAutoCross()
			end
		})
		table.insert(config.menuItems, {
			text = "Restart",
			exec = function()
				context.screen:resetGrid()
			end
		})
	end

	if player.id == PLAYER_ID_QUICK_PLAY then
		if puzzle.hasBeenSolved then
			table.insert(config.menuItems, {
				text = "Solve another",
				exec = function()
					self.onNext()
				end
			})
		end
	else
		if creator.id == player.id or player:hasPlayed(puzzle) then
			table.insert(config.menuItems, {
				text = "Remix puzzle",
				exec = function()
					self.onRemixPuzzle()
				end
			})
		end
		if creator.id == player.id then
			table.insert(config.menuItems, {
				text = "Rotate solution",
				selected = selected == ACTION_ID_ROTATE,
				img = createPuzzlePreview(puzzle),
				exec = function()
					self.onRotatePuzzle()
				end
			})
			table.insert(config.menuItems, {
				text = "Delete puzzle",
				exec = function()
					self.onDeletePuzzle()
				end
			})
		end
	end

	PlayPuzzleSidebar.super.enter(self, context, config)
end

function PlayPuzzleSidebar:getTitle(player, creator, puzzle)
	if creator.id == player.id or player:hasPlayed(puzzle) then
		return "\"" .. puzzle.title .. "\""
	end

	local created = creator.created
	for i = 1, #created do
		if created[i] == puzzle.id then
			return string.format("Puzzle %02d", i)
		end
	end
end
