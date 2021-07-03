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
import "levels"
import "utils"

import "model/done-numbers"
import "model/done-numbers-disabled"
import "model/level"
import "model/numbers"
import "model/player"

import "screen/screen"
import "screen/avatar-create"
import "screen/grid-create"
import "screen/grid-play"
import "screen/grid-solved"
import "screen/title"

import "sidebar/sidebar"
import "sidebar/create-avatar"
import "sidebar/create-grid"
import "sidebar/options"
import "sidebar/play-grid"
import "sidebar/select-avatar"
import "sidebar/select-creator"
import "sidebar/select-level"
import "sidebar/select-mode"
import "sidebar/select-player"
import "sidebar/test-grid"

import "ui/avatar"
import "ui/board"
import "ui/board-numbers"
import "ui/cursor"
import "ui/dialog"
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
imgBoard, err = gfx.imagetable.new("img/board")
assert(imgBoard, err)
imgDialog = gfx.nineSlice.new("img/dialog", 19, 9, 2, 2)

-- screens
local avatarCreate = AvatarCreate()
local gridCreate = GridCreate()
local gridPlay = GridPlay()
local gridSolved = GridSolved()
local title = TitleScreen()

-- sidebars
local createAvatarSidebar = CreateAvatarSidebar()
local createGridSidebar = CreateGridSidebar()
local optionsSidebar = OptionsSidebar()
local playGridSidebar = PlayGridSidebar()
local selectAvatarSidebar = SelectAvatarSidebar()
local selectCreatorSidebar = SelectCreatorSidebar()
local selectLevelSidebar = SelectLevelSidebar()
local selectPlayerSidebar = SelectPlayerSidebar()
local selectModeSidebar = SelectModeSidebar()
local testGridSidebar = TestGridSidebar()

-- modal
local modal = Modal()

local context = {
	creator = nil,
	level = nil,
	player = nil,
	mode = nil,
	save = nil,
	screen = title
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
		if size <= MAX_LEVEL_NAME_SIZE then
			invalid = rawlen(playdate.string.trimWhitespace(text)) == 0
			context.player.name = text
			switchToSidebar(selectPlayerSidebar, mode)
		else
			playdate.keyboard.text = context.player.name
		end
	end

	playdate.keyboard.show(context.player.name)
end

function showLevelKeyboard()
	playdate.keyboard.canDismiss = function ()
		return true
	end

	local invalid = true

	playdate.keyboard.keyboardWillHideCallback = function ()
		if invalid then
			switchToScreen(gridSolved)
			switchToSidebar(testGridSidebar)
		else
			context.level:save(context)

			switchToScreen(title)
			switchToSidebar(selectModeSidebar)
		end
	end

	playdate.keyboard.textChangedCallback = function ()
		local text = playdate.keyboard.text
		gfx.setFont(fontText)
		local size = gfx.getTextSize(text)
		if size <= MAX_LEVEL_NAME_SIZE then
			invalid = rawlen(playdate.string.trimWhitespace(text)) == 0
			context.level.title = text
			switchToSidebar(selectLevelSidebar, LEVEL_ID_SHOW_NAME)
		else
			playdate.keyboard.text = context.level.title
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

avatarCreate.onChanged = function()
	switchToSidebar(createAvatarSidebar)
end

gridCreate.onChanged = function ()
	context.level.hasBeenSolved = false
	switchToSidebar(createGridSidebar)
end

gridPlay.onPlayed = function ()
	switchToScreen(gridSolved)
	if context.mode == MODE_CREATE then
		switchToSidebar(testGridSidebar)
	else
		context.player.played[context.level.id] = true
		context.player:save(context)

		switchToSidebar(selectLevelSidebar, context.level.id)
	end
end

createAvatarSidebar.onAbort = function ()
	switchToScreen(title)
	switchToSidebar(selectAvatarSidebar)
end

createAvatarSidebar.onSave = function()
	context.player.avatar = createAvatarPreview(context.level)

	switchToScreen(title)
	switchToSidebar(selectPlayerSidebar, PLAYER_ID_SHOW_NAME)
	showPlayerKeyboard(PLAYER_ID_SHOW_NAME)
end

createGridSidebar.onAbort = function()
	switchToScreen(title)
	switchToSidebar(selectModeSidebar)
end

createGridSidebar.onTestAndSave = function ()
	switchToScreen(gridPlay)
	switchToSidebar(testGridSidebar)
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
		modal:enter("Deleting your profile won’t delete your levels. Continue anyway?", "Delete")
	end
end

optionsSidebar.onRename = function ()
	switchToSidebar(selectPlayerSidebar, PLAYER_ID_SHOW_RENAME)
	showPlayerKeyboard(PLAYER_ID_SHOW_RENAME)
end

optionsSidebar.onToggleHints = function ()
	context.player.options.hintsDisabled = not context.player.options.hintsDisabled
	context.player:save(context)
	switchToSidebar(optionsSidebar)
end

playGridSidebar.onAbort = function ()
	switchToSidebar(selectLevelSidebar, context.level.id)
	switchToScreen(title)
end

playGridSidebar.onDeletePuzzle = function ()
	modal.onOK = function ()
		context.level:delete(context)
		if #context.creator.created > 0 then
			switchToSidebar(selectLevelSidebar)
		else
			switchToSidebar(selectCreatorSidebar)
		end
		switchToScreen(title)
	end
	modal:enter("Are you sure you want to delete this puzzle?", "Delete")
end

selectAvatarSidebar.onAbort = function()
	switchToSidebar(selectPlayerSidebar)
end

selectAvatarSidebar.onNewAvatar = function ()
	switchToScreen(avatarCreate)
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
	switchToSidebar(selectLevelSidebar)
end

selectLevelSidebar.onAbort = function()
	switchToScreen(title)
	switchToSidebar(selectCreatorSidebar, context.creator.id)
end

selectLevelSidebar.onSelected = function (level)
	context.level = Level(level)
	switchToScreen(gridPlay)
	switchToSidebar(playGridSidebar)
end

selectModeSidebar.onAbort = function()
	switchToSidebar(selectPlayerSidebar, context.player.id)
end

selectModeSidebar.onSelected = function(selectedMode)
	context.mode = selectedMode
	if context.mode == MODE_PLAY then
		switchToSidebar(selectCreatorSidebar)
	elseif context.mode == MODE_CREATE then
		context.level = Level.createEmpty()
		switchToScreen(gridCreate)
		switchToSidebar(createGridSidebar)
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

testGridSidebar.onAbort = function ()
	switchToScreen(gridCreate)
	switchToSidebar(createGridSidebar)
end

testGridSidebar.onSave = function ()
	context.level.title = ""
	switchToSidebar(selectLevelSidebar, LEVEL_ID_SHOW_NAME)
	showLevelKeyboard()
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
