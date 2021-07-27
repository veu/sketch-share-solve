import "CoreLibs/animation"
import "CoreLibs/frameTimer"
import "CoreLibs/graphics"
import "CoreLibs/keyboard"
import "CoreLibs/nineslice"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/string"
import "CoreLibs/timer"
import "CoreLibs/ui/crankIndicator"

import "constants"

import "input/default"
import "input/modal"
import "input/noop"

import "model/done-numbers"
import "model/done-numbers-disabled"
import "model/done-numbers-line"
import "model/numbers"
import "model/profile"
import "model/puzzle"
import "model/settings"

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
import "sidebar/settings"
import "sidebar/test-puzzle"
import "sidebar/title"

import "ui/creator-avatar"
import "ui/cursor"
import "ui/dialog"
import "ui/grid"
import "ui/grid-numbers"
import "ui/list"
import "ui/menu-border"
import "ui/modal"
import "ui/player-avatar"
import "ui/text-cursor"
import "ui/time"
import "ui/timer"
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
imgCursor, err = gfx.imagetable.new("img/cursor")
assert(imgCursor, err)
imgDialog = gfx.nineSlice.new("img/dialog", 19, 9, 2, 2)
imgTitle = gfx.image.new("img/title")
imgMenuBorder = gfx.image.new("img/menu-border")

-- screens
local createAvatarScreen = CreateAvatarScreen()
local createPuzzleScreen = CreatePuzzleScreen()
local solvedPuzzleScreen = SolvedPuzzleScreen()
local playPuzzleScreen = PlayPuzzleScreen()
local titleScreen = TitleScreen()

-- sidebars
local createAvatarSidebar = CreateAvatarSidebar()
local createPuzzleSidebar = CreatePuzzleSidebar()
local namePlayerSidebar = SelectPlayerSidebar()
local namePuzzleSidebar = SelectPuzzleSidebar()
local optionsSidebar = OptionsSidebar()
local playPuzzleSidebar = PlayPuzzleSidebar()
local selectAvatarSidebar = SelectAvatarSidebar()
local selectCreatorSidebar = SelectCreatorSidebar()
local selectPuzzleSidebar = SelectPuzzleSidebar()
local selectPlayerSidebar = SelectPlayerSidebar()
local selectModeSidebar = SelectModeSidebar()
local settingsSidebar = SettingsSidebar()
local testPuzzleSidebar = TestPuzzleSidebar()
local titleSidebar = TitleSidebar()

local context = {
	creator = nil,
	puzzle = nil,
	player = nil,
	modal = Modal(),
	mode = nil,
	save = nil,
	settings = nil,
	screen = titleScreen,
	sidebar = titleSidebar,
	isCrankDocked = true,
}

local defaultInputHandler = createDefaultInputHandler(context)
local modalInputHandler = createModalInputHandler(context)
local noopInputHandler = createNoopInputHandler(context)

function showModal(text, ok)
	context.modal:enter(text, ok)
	playdate.inputHandlers.push(modalInputHandler, true)
	context.modal.onClose = function ()
		playdate.inputHandlers.pop()
	end
end

function showPlayerKeyboard(mode)
	local invalid = false

	playdate.keyboard.keyboardWillHideCallback = function (ok)
		if invalid or not ok then
			switch(nil, mode == PLAYER_ID_SHOW_RENAME and optionsSidebar or selectPlayerSidebar, nil, true)
		else
			context.player:save(context)
			if mode == PLAYER_ID_SHOW_RENAME then
				switch(nil, optionsSidebar, OPTION_ID_RENAME_PROFILE, true)
			else
				switch(nil, selectModeSidebar)
			end
		end
	end

	namePlayerSidebar.onAbort = function()
		invalid = true
		playdate.keyboard.hide()
	end

	playdate.keyboard.textChangedCallback = function ()
		local text = playdate.keyboard.text
		gfx.setFont(fontText)
		local size = gfx.getTextSize(text)
		if size <= MAX_PUZZLE_NAME_SIZE then
			invalid = rawlen(playdate.string.trimWhitespace(text)) == 0
			context.player.name = text
			switch(nil, namePlayerSidebar, mode)
		else
			playdate.keyboard.text = context.player.name
		end
	end

	playdate.keyboard.show(context.player.name)
end

function showPuzzleKeyboard()
	local invalid = true

	playdate.keyboard.keyboardWillHideCallback = function ()
		if invalid then
			switch(solvedPuzzleScreen, testPuzzleSidebar, nil, true)
		else
			context.puzzle:save(context)

			switch(titleScreen, selectModeSidebar, nil, true)
		end
	end

	namePuzzleSidebar.onAbort = function()
		invalid = true
		playdate.keyboard.hide()
	end

	playdate.keyboard.textChangedCallback = function ()
		local text = playdate.keyboard.text
		gfx.setFont(fontText)
		local size = gfx.getTextSize(text)
		if size <= MAX_PUZZLE_NAME_SIZE then
			invalid = rawlen(playdate.string.trimWhitespace(text)) == 0
			context.puzzle.title = text
			switch(nil, namePuzzleSidebar, PUZZLE_ID_SHOW_NAME)
		else
			playdate.keyboard.text = context.puzzle.title
		end
	end

	playdate.keyboard.show(context.puzzle.title)
end

function switch(newScreen, newSidebar, selected, out)
	playdate.inputHandlers.push(noopInputHandler, true)
	if newScreen then
		context.screen:leave()
		context.screen = newScreen
	end
	context.scrolling = newSidebar ~= context.sidebar
	context.scrollOut = out
	context.sidebar.onLeft = function ()
		context.scrolling = false
		if newScreen then
			newScreen:enter(context)
		end
		playdate.inputHandlers.pop()
	end
	context.sidebar:leave(context)
	context.sidebar = newSidebar
	context.sidebar:enter(context, selected)
end

local idleCounter = 0
function resume()
	playdate.start()
	idleCounter = 0
end

createAvatarScreen.onChanged = function()
	switch(nil, createAvatarSidebar)
end

createPuzzleScreen.onChanged = function ()
	context.puzzle.hasBeenSolved = false
	switch(nil, createPuzzleSidebar)
end

playPuzzleScreen.onChanged = function ()
	if context.mode == MODE_CREATE then
		context.puzzle.hasBeenSolved = false
		switch(nil, testPuzzleSidebar)
	end
end

playPuzzleScreen.onPlayed = function (time)
	context.player.lastTime = time
	if context.mode == MODE_CREATE then
		switch(solvedPuzzleScreen, testPuzzleSidebar)
	else
		if context.player.id ~= PLAYER_ID_QUICK_PLAY then
			context.player:setPlayed(context.puzzle, time)
			context.player:save(context)
		end

		switch(solvedPuzzleScreen, playPuzzleSidebar)
	end
end

createAvatarSidebar.onAbort = function ()
	switch(titleScreen, selectAvatarSidebar, nil, true)
end

createAvatarSidebar.onInvertGrid = function ()
	context.screen:invertGrid()
	switch(nil, createAvatarSidebar, ACTION_ID_INVERT_COLORS)
end

createAvatarSidebar.onResetGrid = function()
	context.screen:resetGrid()
	switch(nil, createAvatarSidebar, ACTION_ID_RESET_GRID)
end

createAvatarSidebar.onSave = function()
	context.player:setAvatar(createAvatarPreview(context.puzzle))

	switch(titleScreen, namePlayerSidebar, PLAYER_ID_SHOW_NAME)
	showPlayerKeyboard(PLAYER_ID_SHOW_NAME)
end

createPuzzleSidebar.onAbort = function()
	switch(titleScreen, selectModeSidebar, MODE_CREATE, true)
end

createPuzzleSidebar.onFlip = function()
	context.screen:flipGrid()
	context.puzzle.hasBeenSolved = false
	switch(nil, createPuzzleSidebar, ACTION_ID_FLIP)
end

createPuzzleSidebar.onInvertColors = function()
	context.screen:invertGrid()
	context.puzzle.hasBeenSolved = false
	switch(nil, createPuzzleSidebar, ACTION_ID_INVERT_COLORS)
end

createPuzzleSidebar.onResetGrid = function()
	context.screen:resetGrid()
	context.puzzle.hasBeenSolved = false
	switch(nil, createPuzzleSidebar, ACTION_ID_RESET_GRID)
end

createPuzzleSidebar.onTestAndSave = function ()
	switch(playPuzzleScreen, testPuzzleSidebar)
end

optionsSidebar.onAbort = function ()
	switch(nil, selectModeSidebar, MODE_OPTIONS, true)
end

optionsSidebar.onDelete = function ()
	local delete = function ()
		context.player:delete(context)
		switch(nil, selectPlayerSidebar, nil, true)
	end

	if #context.player.created == 0 then
		delete()
	else
		context.modal.onOK = delete
		showModal("Deleting your profile won’t delete your puzzles. Continue anyway?", "Delete")
	end
end

optionsSidebar.onRename = function ()
	switch(nil, namePlayerSidebar, PLAYER_ID_SHOW_RENAME)
	showPlayerKeyboard(PLAYER_ID_SHOW_RENAME)
end

optionsSidebar.onResetProgress = function ()
	context.modal.onOK = function ()
		context.player.played = {}
		context.player:save(context)
		switch(nil, optionsSidebar, OPTION_ID_RESET_PROGRESS)
	end
	local numPlayed = context.player:getNumPlayed()
	showModal("This will reset " .. numPlayed .. " played puzzles.", "Reset progress")
end

optionsSidebar.onHintsDown = function ()
	context.player.options.showHints = math.max(1, context.player.options.showHints - 1)
	context.player:save(context)
	switch(nil, optionsSidebar)
end

optionsSidebar.onHintsUp = function ()
	context.player.options.showHints = math.min(3, context.player.options.showHints + 1)
	context.player:save(context)
	switch(nil, optionsSidebar)
end

optionsSidebar.onToggleHints = function ()
	context.player.options.showHints = context.player.options.showHints % 3 + 1
	context.player:save(context)
	switch(nil, optionsSidebar)
end

optionsSidebar.onToggleTimer = function ()
	context.player.options.showTimer = not context.player.options.showTimer
	context.player:save(context)
	switch(nil, optionsSidebar, ACTION_ID_TOGGLE_TIMER)
end

playPuzzleSidebar.onAbort = function ()
	if context.player.id == PLAYER_ID_QUICK_PLAY then
		switch(titleScreen, titleSidebar, ACTION_ID_QUICK_PLAY, true)
	else
		switch(titleScreen, selectPuzzleSidebar, context.puzzle.id, true)
	end
end

playPuzzleSidebar.onDeletePuzzle = function ()
	context.modal.onOK = function ()
		context.puzzle:delete(context)
		if #context.creator.created > 0 then
			switch(titleScreen, selectPuzzleSidebar, nil, true)
		else
			switch(titleScreen, selectCreatorSidebar, nil, true)
		end
	end
	showModal("Are you sure you want to delete the puzzle \"" .. context.puzzle.title .. "\"?", "Delete")
end

playPuzzleSidebar.onRemixPuzzle = function ()
	local puzzle = Puzzle.createEmpty()
	puzzle.grid = table.shallowcopy(context.puzzle.grid)
	puzzle.title = context.puzzle.title
	context.puzzle = puzzle
	context.mode = MODE_CREATE
	switch(createPuzzleScreen, createPuzzleSidebar)
end

playPuzzleSidebar.onNext = function ()
	local puzzleId = context.creator.created[math.random(#context.creator.created)]
	context.puzzle = Puzzle.load(context, puzzleId)
	switch(playPuzzleScreen, playPuzzleSidebar)
end

selectAvatarSidebar.onAbort = function()
	switch(nil, selectPlayerSidebar, ACTION_ID_NEW_PLAYER, true)
end

selectAvatarSidebar.onNewAvatar = function ()
	context.puzzle = nil
	switch(createAvatarScreen, createAvatarSidebar)
end

selectAvatarSidebar.onSelected = function(avatar)
	context.player:setAvatar(imgAvatars:getImage(avatar))

	switch(nil, namePlayerSidebar, PLAYER_ID_SHOW_NAME)
	showPlayerKeyboard(PLAYER_ID_SHOW_NAME)
end

selectCreatorSidebar.onAbort = function()
	switch(nil, selectModeSidebar, MODE_PLAY, true)
end

selectCreatorSidebar.onSelected = function(creator)
	context.creator = creator
	switch(nil, selectPuzzleSidebar)
end

selectPuzzleSidebar.onAbort = function()
	switch(nil, selectCreatorSidebar, context.creator.id, true)
end

selectPuzzleSidebar.onSelected = function (puzzle)
	context.puzzle = puzzle
	switch(playPuzzleScreen, playPuzzleSidebar)
end

selectModeSidebar.onAbort = function()
	switch(nil, selectPlayerSidebar, context.player.id, true)
end

selectModeSidebar.onSelected = function(selectedMode)
	context.mode = selectedMode
	if context.mode == MODE_PLAY then
		switch(nil, selectCreatorSidebar)
	elseif context.mode == MODE_CREATE then
		context.puzzle = Puzzle.createEmpty()
		switch(createPuzzleScreen, createPuzzleSidebar)
	else
		switch(nil, optionsSidebar)
	end
end

selectPlayerSidebar.onAbort = function()
	switch(nil, titleSidebar, nil, true)
end

selectPlayerSidebar.onNewPlayer = function()
	context.player = Profile.createEmpty()

	switch(nil, selectAvatarSidebar)
end

selectPlayerSidebar.onSelected = function(player)
	context.player = player

	switch(nil, selectModeSidebar)
end

settingsSidebar.onAbort = function ()
	switch(nil, titleSidebar, ACTION_ID_SETTINGS, true)
end

settingsSidebar.onCrankSpeedDown = function ()
	context.settings.crankSpeed = (context.settings.crankSpeed + 3) % 5 + 1
	context.settings:save(context)
	switch(nil, settingsSidebar)
end

settingsSidebar.onCrankSpeedUp = function ()
	context.settings.crankSpeed = context.settings.crankSpeed % 5 + 1
	context.settings:save(context)
	switch(nil, settingsSidebar)
end

testPuzzleSidebar.onAbort = function ()
	switch(createPuzzleScreen, createPuzzleSidebar, nil, true)
end

testPuzzleSidebar.onResetGrid = function()
	context.screen:resetGrid()
	context.puzzle.hasBeenSolved = false
	switch(nil, testPuzzleSidebar, ACTION_ID_RESET_GRID)
end

testPuzzleSidebar.onSave = function ()
	switch(nil, namePuzzleSidebar, PUZZLE_ID_SHOW_NAME)
	showPuzzleKeyboard()
end

titleSidebar.onPlay = function ()
	switch(nil, selectPlayerSidebar)
end

titleSidebar.onSettings = function ()
	switch(nil, settingsSidebar)
end

titleSidebar.onQuickPlay = function ()
	context.player = Profile.load(context, PLAYER_ID_QUICK_PLAY)
	context.creator = Profile.load(context, PLAYER_ID_RDK, context.ext.rdk)
	local puzzleId = context.creator.created[math.random(#context.creator.created)]
	context.puzzle = Puzzle.load(context, puzzleId, context.ext.rdk)
	context.mode = MODE_PLAY
	switch(playPuzzleScreen, playPuzzleSidebar)
end

math.randomseed(playdate.getSecondsSinceEpoch())

function save(context)
	playdate.datastore.write(context.save, FILE_SAVE, true)
end

context.ext = {}
for i, path in pairs(playdate.file.listFiles()) do
		if string.sub(path, -5, -1) == ".json" then
			local id = string.sub(path, 0, -6)
			if id ~= FILE_SAVE and string.sub(path, 0, 1) ~= "." then
				context.ext[id] = playdate.datastore.read(id)
				context.ext[id].id = id
			end
		end
end

context.save = playdate.datastore.read(FILE_SAVE)
context.settings = Settings.load(context)

playdate.ui.crankIndicator:start()
context.screen:enter(context)
context.sidebar:enter(context)
playdate.inputHandlers.push(defaultInputHandler)

if not playdate.isCrankDocked() then
	context.isCrankDocked = false
	context.screen:crankUndocked()
	context.sidebar:open()
end

local showFPS = false
local menuItem = playdate.getSystemMenu():addMenuItem("toggle fps", function()
	showFPS = not showFPS
end)

function playdate.update()
	context.screen:update()
	local inputHandler = playdate.inputHandlers[#playdate.inputHandlers]
	if inputHandler.update then
		inputHandler.update()
	end

	gfx.sprite.update()
	if
		context.screen.showCrank and
		not context.modal:isVisible() and
		playdate.isCrankDocked()
	then
		playdate.ui.crankIndicator:update()
	elseif playdate.keyboard.isVisible() or context.screen.cantIdle then
		idleCounter = 0
	else
		idleCounter += 1
		if idleCounter > 200 then
			playdate.stop()
		end
	end
	if showFPS then
		playdate.drawFPS(0,0)
	end
	playdate.timer.updateTimers()
	playdate.frameTimer.updateTimers()
end

playdate.display.setRefreshRate(40)
