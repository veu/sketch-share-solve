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
import "screen/screen"
import "screen/grid-create"
import "screen/grid-play"
import "screen/title"
import "sidebar/sidebar"
import "sidebar/create-grid"
import "sidebar/save-grid"
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
local gridCreate = GridCreate()
local gridPlay = GridPlay()
local title = TitleScreen()

-- sidebars
local createGridSidebar = CreateGridSidebar()
local testGridSidebar = TestGridSidebar()
local saveGridSidebar = SaveGridSidebar()
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
local showCrank = true

local sidebar = selectPlayerSidebar

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

gridCreate.onChanged = function ()
	context.level.hasBeenSolved = false
	switchToSidebar(createGridSidebar)
end

gridPlay.onPlayed = function (level)
	context.player.played[level.id] = true

	playdate.datastore.write(context.save)

	switchToSidebar(selectLevelSidebar)
end

gridPlay.onReadyToSave = function ()
	showCrank = true
	switchToSidebar(testGridSidebar)
end

createGridSidebar.onAbort = function()
	switchToScreen(title)
	switchToSidebar(selectModeSidebar)
end

createGridSidebar.onTestAndSave = function ()
	switchToScreen(gridPlay)
	switchToSidebar(testGridSidebar)
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

selectPlayerSidebar.onSelected = function(player)
	showCrank = false
	context.player = player
	switchToSidebar(selectModeSidebar)
end

testGridSidebar.onAbort = function ()
	showCrank = false
	switchToScreen(gridCreate)
	switchToSidebar(createGridSidebar)
end

testGridSidebar.onSave = function ()
	showCrank = false

	context.level.title = ""
	switchToSidebar(saveGridSidebar)

	playdate.keyboard.canDismiss = function ()
		return true
	end
	playdate.keyboard.keyboardWillHideCallback = function (ok)
		if not ok or rawlen(playdate.string.trimWhitespace(context.level.title)) == 0 then
			switchToScreen(gridCreate)
			switchToSidebar(createGridSidebar)
			return
		end

		local id = context.level.id
		local level = {
			id = id,
			title = context.level.title,
			grid = context.level.grid
		}

		context.save.levels[id] = level
		table.insert(context.player.created, id)

		playdate.datastore.write(context.save)

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
	if showCrank and playdate.isCrankDocked() then
		playdate.ui.crankIndicator:update()
	end
	--playdate.drawFPS(0,0)
	playdate.timer.updateTimers()
end
