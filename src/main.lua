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

import "model/done-numbers"
import "model/done-numbers-disabled"
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

-- modal
local modal = Modal()

local context = {
	creator = nil,
	puzzle = nil,
	player = nil,
	mode = nil,
	save = nil,
	settings = nil,
	screen = titleScreen,
	isCrankDocked = true,
}

local sidebar = titleSidebar

function showModal(text)
	modal:enter(text)
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

	playdate.keyboard.show()
end

function switch(newScreen, newSidebar, selected, out)
	if newScreen then
		context.screen:leave()
		context.screen = newScreen
	end
	context.scrolling = newSidebar ~= sidebar
	context.scrollOut = out
	sidebar.onLeft = function ()
		context.scrolling = false
		if newScreen then
			newScreen:enter(context)
		end
	end
	sidebar:leave(context)
	sidebar = newSidebar
	sidebar:enter(context, selected)
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

playPuzzleScreen.onPlayed = function ()
	if context.mode == MODE_CREATE then
		switch(solvedPuzzleScreen, testPuzzleSidebar)
	else
		if context.player.id ~= context.creator.id and context.player.id ~= PLAYER_ID_QUICK_PLAY then
			context.player.played[context.puzzle.id] = true
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
		modal.onOK = delete
		modal:enter("Deleting your profile won’t delete your puzzles. Continue anyway?", "Delete")
	end
end

optionsSidebar.onRename = function ()
	switch(nil, namePlayerSidebar, PLAYER_ID_SHOW_RENAME)
	showPlayerKeyboard(PLAYER_ID_SHOW_RENAME)
end

optionsSidebar.onResetProgress = function ()
	modal.onOK = function ()
		context.player.played = {}
		context.player:save(context)
		switch(nil, optionsSidebar, OPTION_ID_RESET_PROGRESS)
	end
	local numPlayed = context.player:getNumPlayed()
	modal:enter("This will reset " .. numPlayed .. " played puzzles.", "Reset progress")
end

optionsSidebar.onToggleHints = function ()
	context.player.options.hintsDisabled = not context.player.options.hintsDisabled
	context.player:save(context)
	switch(nil, optionsSidebar)
end

playPuzzleSidebar.onAbort = function ()
	if context.player.id == PLAYER_ID_QUICK_PLAY then
		switch(titleScreen, titleSidebar, ACTION_ID_QUICK_PLAY, true)
	else
		switch(titleScreen, selectPuzzleSidebar, context.puzzle.id, true)
	end
end

playPuzzleSidebar.onDeletePuzzle = function ()
	modal.onOK = function ()
		context.puzzle:delete(context)
		if #context.creator.created > 0 then
			switch(titleScreen, selectPuzzleSidebar, nil, true)
		else
			switch(titleScreen, selectCreatorSidebar, nil, true)
		end
	end
	modal:enter("Are you sure you want to delete the puzzle \"" .. context.puzzle.title .. "\"?", "Delete")
end

playPuzzleSidebar.onNext = function ()
	local puzzleId = context.creator.created[math.random(#context.creator.created)]
	context.puzzle = Puzzle.load(context, puzzleId)
	switch(playPuzzleScreen, playPuzzleSidebar)
end

selectAvatarSidebar.onAbort = function()
	switch(nil, selectPlayerSidebar, nil, true)
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
	context.puzzle.title = ""
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
	context.creator = Profile.load(context, PLAYER_ID_RDK)
	local puzzleId = context.creator.created[math.random(#context.creator.created)]
	context.puzzle = Puzzle.load(context, puzzleId)
	switch(playPuzzleScreen, playPuzzleSidebar)
end

function playdate.crankDocked()
	context.isCrankDocked = true
	context.screen:crankDocked()
	sidebar:close()
end

function playdate.crankUndocked()
	context.isCrankDocked = false
	context.screen:crankUndocked()
	sidebar:open()
end

function playdate.cranked(change, acceleratedChange)
	if context.scrolling then
		return
	end
	if not modal:isVisible() then
		local factor = 0.5 + context.settings.crankSpeed * 0.1
		sidebar:cranked(-change * factor, -acceleratedChange * factor)
	end
end

function playdate.downButtonDown()
	if context.scrolling then
		return
	end
	if not modal:isVisible() and not playdate.isCrankDocked() then
		sidebar:downButtonDown()
	end
end

function playdate.leftButtonDown()
	if context.scrolling then
		return
	end
	if not modal:isVisible() and not playdate.isCrankDocked() then
		sidebar:leftButtonDown()
	end
end

function playdate.rightButtonDown()
	if context.scrolling then
		return
	end
	if not modal:isVisible() and not playdate.isCrankDocked() then
		sidebar:rightButtonDown()
	end
end

function playdate.upButtonDown()
	if context.scrolling then
		return
	end
	if not modal:isVisible() and not playdate.isCrankDocked() then
		sidebar:upButtonDown()
	end
end

function playdate.AButtonDown()
	if context.scrolling then
		return
	end
	if modal:isVisible() then
		modal:AButtonDown()
	elseif playdate.isCrankDocked() then
		context.screen:AButtonDown()
	else
		sidebar:AButtonDown()
	end
end

function playdate.BButtonDown()
	if context.scrolling then
		return
	end
	if modal:isVisible() then
		modal:BButtonDown()
	elseif playdate.isCrankDocked() then
		context.screen:BButtonDown()
	else
		sidebar:BButtonDown()
	end
end

math.randomseed(playdate.getSecondsSinceEpoch())

-- playdate.datastore.write(json.decodeFile("./save.json"))
context.save = playdate.datastore.read() or json.decodeFile("./save.json")
context.settings = Settings.load(context)

playdate.ui.crankIndicator:start()
context.screen:enter(context)
sidebar:enter(context)

if not playdate.isCrankDocked() then
	context.isCrankDocked = false
	context.screen:crankUndocked()
	sidebar:open()
end

function playdate.update()
	context.screen:update()

	gfx.sprite.update()
	if context.screen.showCrank and playdate.isCrankDocked() then
		playdate.ui.crankIndicator:update()
	end
	--playdate.drawFPS(0,0)
	playdate.timer.updateTimers()
end
