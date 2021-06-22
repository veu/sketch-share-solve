import "CoreLibs/graphics"
import "CoreLibs/keyboard"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/string"
import "CoreLibs/timer"
import "CoreLibs/ui/crankIndicator"
import "CoreLibs/ui/gridview"

import "constants"
import "input"
import "levels"
import "utils"
import "model/level"
import "model/numbers"
import "model/player"

import "screen/screen"
import "screen/avatar-create"
import "screen/grid-create"
import "screen/grid-play"
import "screen/title"

import "sidebar/sidebar"
import "sidebar/create-avatar"
import "sidebar/create-grid"
import "sidebar/name-player"
import "sidebar/save-grid"
import "sidebar/select-avatar"
import "sidebar/select-creator"
import "sidebar/select-level"
import "sidebar/select-mode"
import "sidebar/select-player"
import "sidebar/test-grid"

import "ui/board"
import "ui/board-numbers"
import "ui/cursor"
import "ui/dialog"
import "ui/list"
import "ui/title"
import "utils/ui"

local gfx <const> = playdate.graphics

fontGrid = gfx.font.new("font/grid")
assert(fontGrid)
fontText = gfx.font.new("font/text")
assert(fontText)
imgAvatars, err = gfx.imagetable.new("img/avatars")
assert(imgAvatars, err)
imgBoard, err = gfx.imagetable.new("img/board")
assert(imgBoard, err)

-- screens
local avatarCreate = AvatarCreate()
local gridCreate = GridCreate()
local gridPlay = GridPlay()
local title = TitleScreen()

-- sidebars
local createAvatarSidebar = CreateAvatarSidebar()
local createGridSidebar = CreateGridSidebar()
local namePlayerSidebar = NamePlayerSidebar()
local testGridSidebar = TestGridSidebar()
local saveGridSidebar = SaveGridSidebar()
local selectAvatarSidebar = SelectAvatarSidebar()
local selectCreatorSidebar = SelectCreatorSidebar()
local selectLevelSidebar = SelectLevelSidebar()
local selectPlayerSidebar = SelectPlayerSidebar()
local selectModeSidebar = SelectModeSidebar()

local context = {
	creator = nil,
	level = nil,
	player = nil,
	mode = nil,
	save = nil,
	screen = title
}

local sidebar = selectPlayerSidebar

function showPlayerKeyboard()
	playdate.keyboard.canDismiss = function ()
		return true
	end

	playdate.keyboard.keyboardWillHideCallback = function (ok)
		if not ok or rawlen(playdate.string.trimWhitespace(context.player.name)) == 0 then
			switchToSidebar(selectAvatarSidebar)
			return
		end

		context.player:save(context)

		switchToSidebar(selectModeSidebar)
	end

	playdate.keyboard.textChangedCallback = function ()
		local text = playdate.keyboard.text
		gfx.setFont(fontText)
		local size = gfx.getTextSize(text)
		if size <= MAX_LEVEL_NAME_SIZE then
			context.player.name = text
			switchToSidebar(namePlayerSidebar)
		else
			playdate.keyboard.text = context.player.name
		end
	end

	playdate.keyboard.show()
end

function showLevelKeyboard()
	playdate.keyboard.canDismiss = function ()
		return true
	end
	playdate.keyboard.keyboardWillHideCallback = function (ok)
		if not ok or rawlen(playdate.string.trimWhitespace(context.level.title)) == 0 then
			switchToScreen(gridCreate)
			switchToSidebar(createGridSidebar)
			return
		end

		context.level:save(context)

		switchToScreen(title)
		switchToSidebar(selectModeSidebar)
	end

	playdate.keyboard.textChangedCallback = function ()
		local text = playdate.keyboard.text
		gfx.setFont(fontText)
		local size = gfx.getTextSize(text)
		if size <= MAX_LEVEL_NAME_SIZE then
			context.level.title = text
			switchToSidebar(saveGridSidebar)
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

function switchToSidebar(newSidebar)
	sidebar:leave()
	sidebar = newSidebar
	sidebar:enter(context)
end

avatarCreate.onChanged = function()
	switchToSidebar(createAvatarSidebar)
end

gridCreate.onChanged = function ()
	context.level.hasBeenSolved = false
	switchToSidebar(createGridSidebar)
end

gridPlay.onPlayed = function (level)
	context.player.played[level.id] = true

	context.player:save(context)

	switchToSidebar(selectLevelSidebar)
end

gridPlay.onReadyToSave = function ()
	switchToSidebar(testGridSidebar)
end

createAvatarSidebar.onAbort = function ()
	switchToSidebar(selectAvatarSidebar)
end

createAvatarSidebar.onSave = function()
	context.player.avatar = createAvatarPreview(context.level)

	switchToScreen(title)
	switchToSidebar(namePlayerSidebar)
	showPlayerKeyboard()
end

createGridSidebar.onAbort = function()
	switchToScreen(title)
	switchToSidebar(selectModeSidebar)
end

createGridSidebar.onTestAndSave = function ()
	switchToScreen(gridPlay)
	switchToSidebar(testGridSidebar)
end

namePlayerSidebar.onAbort = function()
	switchToSidebar(selectAvatarSidebar)
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

	switchToSidebar(namePlayerSidebar)
	showPlayerKeyboard()
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
	switchToSidebar(selectCreatorSidebar)
end

selectLevelSidebar.onSelected = function (level)
	context.level = Level(level)
	switchToScreen(gridPlay)
end

selectModeSidebar.onAbort = function()
	switchToSidebar(selectPlayerSidebar)
end

selectModeSidebar.onSelected = function(selectedMode)
	context.mode = selectedMode
	if context.mode == MODE_PLAY then
		switchToSidebar(selectCreatorSidebar)
	else
		context.level = Level.createEmpty()
		switchToScreen(gridCreate)
		switchToSidebar(createGridSidebar)
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
	switchToSidebar(saveGridSidebar)
	showLevelKeyboard()
end

function playdate.crankDocked()
	sidebar:close()
end

function playdate.crankUndocked()
	sidebar:open()
end

function playdate.cranked(change, acceleratedChange)
	sidebar:cranked(-change, -acceleratedChange)
end

function playdate.AButtonDown()
	if playdate.isCrankDocked() then
		context.screen:AButtonDown()
	else
		sidebar:AButtonDown()
	end
end

function playdate.BButtonDown()
	if playdate.isCrankDocked() then
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
