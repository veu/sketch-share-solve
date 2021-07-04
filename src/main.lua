import "CoreLibs/animation"
import "CoreLibs/graphics"
import "CoreLibs/keyboard"
import "CoreLibs/nineslice"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/string"
import "CoreLibs/timer"
import "CoreLibs/ui/crankIndicator"

import "constants"
import "input"
import "save"
import "utils"

import "model/done-numbers"
import "model/done-numbers-disabled"
import "model/numbers"
import "model/player"
import "model/puzzle"

import "screen/screen"
import "screen/create-avatar"
import "screen/create-puzzle"
import "screen/play-puzzle"
import "screen/solved-puzzle"
import "screen/title"

import "sidebar/sidebar"
import "sidebar/create-avatar"
import "sidebar/create-puzzle"
import "sidebar/options"
import "sidebar/play-puzzle"
import "sidebar/select-avatar"
import "sidebar/select-creator"
import "sidebar/select-mode"
import "sidebar/select-player"
import "sidebar/select-puzzle"
import "sidebar/test-puzzle"

import "ui/avatar"
import "ui/cursor"
import "ui/dialog"
import "ui/grid"
import "ui/grid-cell"
import "ui/grid-numbers"
import "ui/list"
import "ui/modal"
import "ui/text-cursor"
import "ui/title"

import "utils/numbers"
import "utils/ui"

local gfx <const> = playdate.graphics

fontGrid = gfx.font.newFamily({
	[playdate.graphics.font.kVariantNormal] = "font/grid",
	[playdate.graphics.font.kVariantBold] = "font/grid-bold"
})
assert(fontGrid)

fontText = gfx.font.new("font/text")
assert(fontText)
imgAvatars, err = gfx.imagetable.new("img/avatars")
assert(imgAvatars, err)
imgGrid, err = gfx.imagetable.new("img/grid")
assert(imgGrid, err)
imgDialog = gfx.nineSlice.new("img/dialog", 19, 9, 2, 2)
imgTitle = gfx.image.new("img/title")

-- screens
local createAvatarScreen = CreateAvatarScreen()
local createPuzzleScreen = CreatePuzzleScreen()
local solvedPuzzleScreen = SolvedPuzzleScreen()
local playPuzzleScreen = PlayPuzzleScreen()
local titleScreen = TitleScreen()

-- sidebars
local createAvatarSidebar = CreateAvatarSidebar()
local createPuzzleSidebar = CreatePuzzleSidebar()
local optionsSidebar = OptionsSidebar()
local playPuzzleSidebar = PlayPuzzleSidebar()
local selectAvatarSidebar = SelectAvatarSidebar()
local selectCreatorSidebar = SelectCreatorSidebar()
local selectPuzzleSidebar = SelectPuzzleSidebar()
local selectPlayerSidebar = SelectPlayerSidebar()
local selectModeSidebar = SelectModeSidebar()
local testPuzzleSidebar = TestPuzzleSidebar()

-- modal
local modal = Modal()

local context = {
	creator = nil,
	puzzle = nil,
	player = nil,
	mode = nil,
	save = nil,
	screen = titleScreen
}

local sidebar = selectPlayerSidebar

function showModal(text)
	modal:enter(text)
end

function showPlayerKeyboard(mode)
	playdate.keyboard.canDismiss = function ()
		return true
	end

	local invalid = mode == PLAYER_ID_SHOW_NAME

	playdate.keyboard.keyboardWillHideCallback = function ()
		if invalid then
			switchToSidebar(mode == PLAYER_ID_SHOW_RENAME and optionsSidebar or selectPlayerSidebar)
		else
			context.player:save(context)

			switchToSidebar(mode == PLAYER_ID_SHOW_RENAME and optionsSidebar or selectModeSidebar)
		end
	end

	playdate.keyboard.textChangedCallback = function ()
		local text = playdate.keyboard.text
		gfx.setFont(fontText)
		local size = gfx.getTextSize(text)
		if size <= MAX_PUZZLE_NAME_SIZE then
			invalid = rawlen(playdate.string.trimWhitespace(text)) == 0
			context.player.name = text
			switchToSidebar(selectPlayerSidebar, mode)
		else
			playdate.keyboard.text = context.player.name
		end
	end

	playdate.keyboard.show(context.player.name)
end

function showPuzzleKeyboard()
	playdate.keyboard.canDismiss = function ()
		return true
	end

	local invalid = true

	playdate.keyboard.keyboardWillHideCallback = function ()
		if invalid then
			switchToScreen(solvedPuzzleScreen)
			switchToSidebar(testPuzzleSidebar)
		else
			context.puzzle:save(context)

			switchToScreen(titleScreen)
			switchToSidebar(selectModeSidebar)
		end
	end

	playdate.keyboard.textChangedCallback = function ()
		local text = playdate.keyboard.text
		gfx.setFont(fontText)
		local size = gfx.getTextSize(text)
		if size <= MAX_PUZZLE_NAME_SIZE then
			invalid = rawlen(playdate.string.trimWhitespace(text)) == 0
			context.puzzle.title = text
			switchToSidebar(selectPuzzleSidebar, PUZZLE_ID_SHOW_NAME)
		else
			playdate.keyboard.text = context.puzzle.title
		end
	end

	playdate.keyboard.show()
end

function switchToScreen(newScreen)
	context.screen:leave()
	context.screen = newScreen
	context.screen:enter(context)
end

function switchToSidebar(newSidebar, selected)
	sidebar:leave()
	sidebar = newSidebar
	sidebar:enter(context, selected)
end

createAvatarScreen.onChanged = function()
	switchToSidebar(createAvatarSidebar)
end

createPuzzleScreen.onChanged = function ()
	context.puzzle.hasBeenSolved = false
	switchToSidebar(createPuzzleSidebar)
end

playPuzzleScreen.onPlayed = function ()
	switchToScreen(solvedPuzzleScreen)
	if context.mode == MODE_CREATE then
		switchToSidebar(testPuzzleSidebar)
	else
		context.player.played[context.puzzle.id] = true
		context.player:save(context)

		switchToSidebar(selectPuzzleSidebar, context.puzzle.id)
	end
end

createAvatarSidebar.onAbort = function ()
	switchToScreen(titleScreen)
	switchToSidebar(selectAvatarSidebar)
end

createAvatarSidebar.onSave = function()
	context.player.avatar = createAvatarPreview(context.puzzle)

	switchToScreen(titleScreen)
	switchToSidebar(selectPlayerSidebar, PLAYER_ID_SHOW_NAME)
	showPlayerKeyboard(PLAYER_ID_SHOW_NAME)
end

createPuzzleSidebar.onAbort = function()
	switchToScreen(titleScreen)
	switchToSidebar(selectModeSidebar)
end

createPuzzleSidebar.onTestAndSave = function ()
	switchToScreen(playPuzzleScreen)
	switchToSidebar(testPuzzleSidebar)
end

optionsSidebar.onAbort = function ()
	switchToSidebar(selectModeSidebar)
end

optionsSidebar.onDelete = function ()
	local delete = function ()
		context.player:delete(context)
		switchToSidebar(selectPlayerSidebar)
	end

	if #context.player.created == 0 then
		delete()
	else
		modal.onOK = delete
		modal:enter("Deleting your profile won’t delete your puzzles. Continue anyway?", "Delete")
	end
end

optionsSidebar.onRename = function ()
	switchToSidebar(selectPlayerSidebar, PLAYER_ID_SHOW_RENAME)
	showPlayerKeyboard(PLAYER_ID_SHOW_RENAME)
end

optionsSidebar.onResetProgress = function ()
	context.player.played = {}
	context.player:save(context)

	switchToSidebar(selectModeSidebar)
end

optionsSidebar.onToggleHints = function ()
	context.player.options.hintsDisabled = not context.player.options.hintsDisabled
	context.player:save(context)
	switchToSidebar(optionsSidebar)
end

playPuzzleSidebar.onAbort = function ()
	switchToScreen(titleScreen)
	switchToSidebar(selectPuzzleSidebar, context.puzzle.id)
end

playPuzzleSidebar.onDeletePuzzle = function ()
	modal.onOK = function ()
		context.puzzle:delete(context)
		if #context.creator.created > 0 then
			switchToSidebar(selectPuzzleSidebar)
		else
			switchToSidebar(selectCreatorSidebar)
		end
		switchToScreen(titleScreen)
	end
	modal:enter("Are you sure you want to delete the puzzle \"" .. context.puzzle.title .. "\"?", "Delete")
end

selectAvatarSidebar.onAbort = function()
	switchToSidebar(selectPlayerSidebar)
end

selectAvatarSidebar.onNewAvatar = function ()
	switchToScreen(createAvatarScreen)
	switchToSidebar(createAvatarSidebar)
end

selectAvatarSidebar.onSelected = function(avatar)
	local player = context.player
	player.avatar = imgAvatars:getImage(avatar)

	switchToSidebar(selectPlayerSidebar, PLAYER_ID_SHOW_NAME)
	showPlayerKeyboard(PLAYER_ID_SHOW_NAME)
end

selectCreatorSidebar.onAbort = function()
	switchToSidebar(selectModeSidebar)
end

selectCreatorSidebar.onSelected = function(creator)
	context.creator = creator
	switchToSidebar(selectPuzzleSidebar)
end

selectPuzzleSidebar.onAbort = function()
	switchToScreen(titleScreen)
	switchToSidebar(selectCreatorSidebar, context.creator.id)
end

selectPuzzleSidebar.onSelected = function (puzzle)
	context.puzzle = Puzzle(puzzle)
	switchToScreen(playPuzzleScreen)
	switchToSidebar(playPuzzleSidebar)
end

selectModeSidebar.onAbort = function()
	switchToSidebar(selectPlayerSidebar, context.player.id)
end

selectModeSidebar.onSelected = function(selectedMode)
	context.mode = selectedMode
	if context.mode == MODE_PLAY then
		switchToSidebar(selectCreatorSidebar)
	elseif context.mode == MODE_CREATE then
		context.puzzle = Puzzle.createEmpty()
		switchToScreen(createPuzzleScreen)
		switchToSidebar(createPuzzleSidebar)
	else
		switchToSidebar(optionsSidebar)
	end
end

selectPlayerSidebar.onNewPlayer = function()
	context.player = Player.createEmpty()

	switchToSidebar(selectAvatarSidebar)
end

selectPlayerSidebar.onSelected = function(player)
	context.player = player

	switchToSidebar(selectModeSidebar)
end

testPuzzleSidebar.onAbort = function ()
	switchToScreen(createPuzzleScreen)
	switchToSidebar(createPuzzleSidebar)
end

testPuzzleSidebar.onSave = function ()
	context.puzzle.title = ""
	switchToSidebar(selectPuzzleSidebar, PUZZLE_ID_SHOW_NAME)
	showPuzzleKeyboard()
end

function playdate.crankDocked()
	sidebar:close()
end

function playdate.crankUndocked()
	sidebar:open()
end

function playdate.cranked(change, acceleratedChange)
	if not modal:isVisible() then
		sidebar:cranked(-change, -acceleratedChange)
	end
end

function playdate.downButtonDown()
	if not modal:isVisible() and not playdate.isCrankDocked() then
		sidebar:downButtonDown()
	end
end

function playdate.upButtonDown()
	if not modal:isVisible() and not playdate.isCrankDocked() then
		sidebar:upButtonDown()
	end
end

function playdate.AButtonDown()
	if modal:isVisible() then
		modal:AButtonDown()
	elseif playdate.isCrankDocked() then
		context.screen:AButtonDown()
	else
		sidebar:AButtonDown()
	end
end

function playdate.BButtonDown()
	if modal:isVisible() then
		modal:BButtonDown()
	elseif playdate.isCrankDocked() then
		context.screen:BButtonDown()
	else
		sidebar:BButtonDown()
	end
end

math.randomseed(playdate.getSecondsSinceEpoch())

--playdate.datastore.write(DEFAULT_SAVE)
context.save = playdate.datastore.read() or DEFAULT_SAVE

playdate.ui.crankIndicator:start()
context.screen:enter(context)
sidebar:enter(context)

function playdate.update()
	context.screen:update()

	gfx.sprite.update()
	if context.screen.showCrank and playdate.isCrankDocked() then
		playdate.ui.crankIndicator:update()
	end
	--playdate.drawFPS(0,0)
	playdate.timer.updateTimers()
end
