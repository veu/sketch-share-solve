import "imports"

-- screens
local aboutScreen <const> = AboutScreen()
local createAvatarScreen <const> = CreateAvatarScreen()
local createPuzzleScreen <const> = CreatePuzzleScreen()
local selectPuzzleScreen <const> = SelectPuzzleScreen()
local sketchTutorialScreen <const> = SketchTutorialScreen()
local solvedPuzzleScreen <const> = SolvedPuzzleScreen()
local solveTutorialScreen <const> = SolveTutorialScreen()
local playPuzzleScreen <const> = PlayPuzzleScreen()
local titleScreen <const> = TitleScreen()

-- sidebars
local aboutSidebar <const> = AboutSidebar()
local changeAvatarSidebar <const> = ChangeAvatarSidebar()
local createAvatarSidebar <const> = CreateAvatarSidebar()
local createPuzzleSidebar <const> = CreatePuzzleSidebar()
local deletePuzzlesSidebar <const> = DeletePuzzlesSidebar()
local namePlayerSidebar <const> = SelectPlayerSidebar()
local namePuzzleSidebar <const> = NamePuzzleSidebar()
local optionsSidebar <const> = OptionsSidebar()
local playPuzzleSidebar <const> = PlayPuzzleSidebar()
local selectAvatarSidebar <const> = SelectAvatarSidebar()
local selectCreatorSidebar <const> = SelectCreatorSidebar()
local selectPuzzleSidebar <const> = SelectPuzzleSidebar()
local selectPlayerSidebar <const> = SelectPlayerSidebar()
local selectModeSidebar <const> = SelectModeSidebar()
local selectTutorialSidebar <const> = SelectTutorialSidebar()
local settingsSidebar <const> = SettingsSidebar()
local shareSidebar <const> = ShareSidebar()
local sketchTutorialSidebar <const> = TutorialSidebar()
local solveTutorialSidebar <const> = TutorialSidebar()
local testPuzzleSidebar <const> = TestPuzzleSidebar()
local titleSidebar <const> = TitleSidebar()

local context <const> = {
	creator = nil,
	puzzle = nil,
	player = nil,
	modal = Modal(),
	mode = nil,
	save = nil,
	settings = nil,
	screen = titleScreen,
	sidebar = titleSidebar,
	isSidebarOpen = false,
}

local defaultInputHandler <const> = createDefaultInputHandler(context)
local modalInputHandler <const> = createModalInputHandler(context)
local noopInputHandler <const> = createNoopInputHandler(context)
local undoInputHandler <const> = createUndoInputHandler(context)

local openMenuItem = nil

function openSidebar()
	if not context.isSidebarOpen then
		if context.screen == createPuzzleScreen then
			switch(nil, createPuzzleSidebar)
		end
		if context.undo then
			endUndo()
		end

		context.isSidebarOpen = true
		context.screen:sidebarOpened()
		context.sidebar:open()
		if openMenuItem then
			playdate.getSystemMenu():removeMenuItem(openMenuItem)
			openMenuItem = nil
		end
	end
end

function closeSidebar()
	if context.isSidebarOpen and not context.sidebar.stayOpen then
		context.isSidebarOpen = false
		context.screen:sidebarClosed()
		context.sidebar:close()
		openMenuItem = playdate.getSystemMenu():addMenuItem("game menu", function()
			resume()
			openSidebar()
		end)
	end
end

function showModal(text, ok)
	context.modal:enter(text, ok)
	playdate.inputHandlers.push(modalInputHandler, true)
	context.modal.onClose = function ()
		playdate.inputHandlers.pop()
	end
end

function showPlayerKeyboard(mode)
	local text = limitToMax(unescapeString(context.player.name))
	local invalid = false

	playdate.keyboard.keyboardWillHideCallback = function (ok)
		if invalid or not ok then
			switch(
				nil,
				mode == PLAYER_ID_SHOW_RENAME and optionsSidebar or selectPlayerSidebar,
				mode == PLAYER_ID_SHOW_RENAME and OPTION_ID_RENAME_PROFILE or ACTION_ID_NEW_PLAYER,
				true
			)
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
		local newText = playdate.keyboard.text
		local escapedText = escapeString(newText)
		if isOverMax(escapedText) then
			playdate.keyboard.text = context.player.name
		else
			invalid = rawlen(playdate.string.trimWhitespace(newText)) == 0
			context.player.name = escapedText
			switch(nil, namePlayerSidebar, mode)
		end
	end

	playdate.keyboard.show(text)
end

function showPuzzleKeyboard()
	local text = limitToMax(unescapeString(context.puzzle.title))
	local invalid = #text == 0

	playdate.keyboard.keyboardWillHideCallback = function ()
		if invalid then
			switch(solvedPuzzleScreen, testPuzzleSidebar, nil, true)
		else
			context.player.sketch = nil
			context.player:setPlayed(context.puzzle, context.player.lastTime)
			context.player:save(context)
			context.puzzle:save(context)

			context.creator = context.player
			context.mode = MODE_PLAY
			switch(selectPuzzleScreen, selectPuzzleSidebar, context.puzzle.id, true)
		end
	end

	namePuzzleSidebar.onAbort = function()
		invalid = true
		playdate.keyboard.hide()
	end

	playdate.keyboard.textChangedCallback = function ()
		local newText = playdate.keyboard.text
		local escapedText = escapeString(newText)
		if isOverMax(escapedText) then
			playdate.keyboard.text = text
		else
			invalid = rawlen(playdate.string.trimWhitespace(newText)) == 0
			text = newText
			context.puzzle.title = escapedText
			switch(nil, namePuzzleSidebar)
		end
	end

	playdate.keyboard.show(text)
end

function switch(newScreen, newSidebar, selected, out, onReady)
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
		if onReady then
			onReady()
		end
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

function playEffect(name)
	if context.settings.effects > 1 then
		if snd1[name]:isPlaying() then
			snd2[name]:play()
		else
			snd1[name]:play()
		end
	end
end

function playTrack()
	if MUSIC_ENABLED and context.settings.music > 1 and not music:isPlaying() then
		music:play(0)
	end
end

function stopTrack()
	if MUSIC_ENABLED then
		music:stop()
	end
end

function startUndo()
	closeSidebar()
	context.screen:startUndo()
	if playdate.isCrankDocked() then
		playdate.ui.crankIndicator:start()
	end
	context.undo = true
	playdate.inputHandlers.push(undoInputHandler, true)
end

function endUndo()
	context.screen:endUndo()
	context.undo = false
	playdate.inputHandlers.pop()
end

local onHintStylePrevious <const> = function ()
	context.settings.hintStyle = (context.settings.hintStyle) % 3 + 2
	context.settings:save(context)
	switch(nil, context.sidebar, ACTION_ID_HINT_STYLE)
	context.screen:updateHintStyle(context)
end

local onHintStyleNext <const> = function ()
	context.settings.hintStyle = (context.settings.hintStyle - 1) % 3 + 2
	context.settings:save(context)
	switch(nil, context.sidebar, ACTION_ID_HINT_STYLE)
	context.screen:updateHintStyle(context)
end

local updateMusicSetting <const> = function (value)
	context.settings.music = value
	context.settings:save(context)
	if value > 1 then
		musicChannel:setVolume((value - 1) / 6.25 + 0.2)
		playTrack()
	else
		stopTrack()
	end
end

local onMusicDown <const> = function ()
	updateMusicSetting((context.settings.music + 4) % 6 + 1)
	switch(nil, context.sidebar, ACTION_ID_MUSIC)
end

local onMusicUp <const> = function ()
	updateMusicSetting(context.settings.music % 6 + 1)
	switch(nil, context.sidebar, ACTION_ID_MUSIC)
end

local updateEffectsSetting <const> = function (value)
	context.settings.effects = value
	context.settings:save(context)
	sndChannel:setVolume((value - 1) / 6.25 + 0.2)
end

local onEffectsDown <const> = function ()
	updateEffectsSetting((context.settings.effects + 4) % 6 + 1)
	switch(nil, context.sidebar, ACTION_ID_EFFECTS)
end

local onEffectsUp <const> = function ()
	updateEffectsSetting(context.settings.effects % 6 + 1)
	switch(nil, context.sidebar, ACTION_ID_EFFECTS)
end

createAvatarScreen.onChanged = function()
	switch(nil, context.sidebar)
end

createPuzzleScreen.onChanged = function ()
	context.puzzle.hasBeenSolved = false
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

aboutSidebar.onAbort = function ()
	switch(titleScreen, titleSidebar, ACTION_ID_ABOUT, true)
end

changeAvatarSidebar.onAbort = function ()
	switch(titleScreen, optionsSidebar, OPTION_ID_CHANGE_AVATAR, true)
end

changeAvatarSidebar.onInvertGrid = function ()
	context.screen:invertGrid()
	switch(nil, changeAvatarSidebar, ACTION_ID_INVERT_COLORS)
end

changeAvatarSidebar.onResetGrid = function()
	context.screen:resetGrid()
	switch(nil, changeAvatarSidebar, ACTION_ID_RESET_GRID)
end

changeAvatarSidebar.onSave = function()
	context.player:setAvatar(createAvatarPreview(context.puzzle))
	context.player:save(context)

	switch(titleScreen, optionsSidebar, OPTION_ID_CHANGE_AVATAR, true)
end

createAvatarSidebar.onAbort = function ()
	switch(titleScreen, selectAvatarSidebar, AVATAR_ID_CREATE_AVATAR, true)
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

	switch(titleScreen, namePlayerSidebar, PLAYER_ID_SHOW_NAME, nil, function()
		showPlayerKeyboard(PLAYER_ID_SHOW_NAME)
	end)
end

createPuzzleSidebar.onAbort = function()
	context.player.sketch = table.concat(context.puzzle.grid)
	context.player:save(context)
	switch(titleScreen, selectModeSidebar, MODE_CREATE, true)
end

createPuzzleSidebar.onFlip = function()
	context.screen:flipGridX()
	context.puzzle.hasBeenSolved = false
	switch(nil, createPuzzleSidebar, ACTION_ID_FLIP)
end

createPuzzleSidebar.onFlipY = function()
	context.screen:flipGridY()
	context.puzzle.hasBeenSolved = false
	switch(nil, createPuzzleSidebar, ACTION_ID_FLIP_Y)
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
	if context.puzzle.hasBeenSolved then
		switch(solvedPuzzleScreen, testPuzzleSidebar)
	else
		switch(playPuzzleScreen, testPuzzleSidebar)
	end
end

createPuzzleSidebar.onUndo = function ()
	startUndo()
end

deletePuzzlesSidebar.onAbort = function()
	switch(nil, settingsSidebar, ACTION_ID_DELETE_PUZZLES, true)
end

deletePuzzlesSidebar.onSelected = function (profile)
	local save <const> = profile._save
	if #save.profileList == 1 then
		-- delete file
		playdate.datastore.delete(DIR_IMPORT .. "/" .. save.id)
		context.ext[profile._save.id] = nil
	else
		-- remove profile, save file
		local savedProfileId = nil
		for id, savedProfile in pairs(save.profiles) do
			if savedProfile.id == profile.id then
				savedProfileId = id
				break
			end
		end
		if savedProfileId then
			save.profiles[savedProfileId] = nil
			for i = 1, #save.profileList do
				if save.profileList[i] == savedProfileId then
					save.profileList[i] = nil
					break
				end
			end
		end
		context.ext[profile._save.id] = save
		playdate.datastore.write(save, DIR_IMPORT .. "/" .. profile._save.id)
	end
	switch(nil, deletePuzzlesSidebar)
end

optionsSidebar.onAbort = function ()
	switch(nil, selectModeSidebar, MODE_OPTIONS, true)
end

optionsSidebar.onChangeAvatar = function ()
	context.puzzle = nil
	switch(createAvatarScreen, changeAvatarSidebar)
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
		showModal("Deleting your profile will delete your created puzzles as well. Continue anyway?", "Delete")
	end
end

optionsSidebar.onRename = function ()
	switch(nil, namePlayerSidebar, PLAYER_ID_SHOW_RENAME, nil, function()
		showPlayerKeyboard(PLAYER_ID_SHOW_RENAME)
	end)
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
	context.player.options.showHints = (context.player.options.showHints + 1) % 3 + 1
	context.player:save(context)
	switch(nil, optionsSidebar)
end

optionsSidebar.onHintsUp = function ()
	context.player.options.showHints = context.player.options.showHints % 3 + 1
	context.player:save(context)
	switch(nil, optionsSidebar)
end

optionsSidebar.onToggleAutoCross = function ()
	context.player.options.autoCross = not context.player.options.autoCross
	context.player:save(context)
	switch(nil, optionsSidebar, ACTION_ID_TOGGLE_AUTOCROSS)
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
		switch(selectPuzzleScreen, selectPuzzleSidebar, context.puzzle.id, true)
	end
end

playPuzzleSidebar.onDeletePuzzle = function ()
	context.modal.onOK = function ()
		context.puzzle:delete(context)
		if #context.creator.created > 0 then
			switch(selectPuzzleScreen, selectPuzzleSidebar, nil, true)
		else
			switch(titleScreen, selectCreatorSidebar, nil, true)
		end
	end
	showModal("Are you sure you want to delete the puzzle \"" .. context.puzzle.title .. "\"?", "Delete")
end

playPuzzleSidebar.onRotatePuzzle = function ()
	context.puzzle:rotate(context)
	if context.screen == solvedPuzzleScreen then
		switch(solvedPuzzleScreen, playPuzzleSidebar, ACTION_ID_ROTATE, true)
	else
		switch(nil, playPuzzleSidebar, ACTION_ID_ROTATE, true)
	end
end

playPuzzleSidebar.onHintStylePrevious = onHintStylePrevious
playPuzzleSidebar.onHintStyleNext = onHintStyleNext
playPuzzleSidebar.onUndo = function ()
	startUndo()
end

playPuzzleSidebar.onRemixPuzzle = function ()
	local puzzle = Puzzle.createEmpty()
	puzzle.grid = table.shallowcopy(context.puzzle.grid)
	puzzle.title = context.puzzle.title
	puzzle.rotation = context.puzzle.rotation
	puzzle.hasBeenSolved = true
	context.player.lastTime = context.player:hasPlayed(context.puzzle)
	context.puzzle = puzzle
	context.mode = MODE_CREATE
	switch(createPuzzleScreen, createPuzzleSidebar)
end

playPuzzleSidebar.onNext = function ()
	local puzzleId = context.creator.created[math.random(#context.creator.created)]
	context.puzzle = Puzzle.load(context, puzzleId, context.ext.rdk)
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

	switch(nil, namePlayerSidebar, PLAYER_ID_SHOW_NAME, nil, function()
		showPlayerKeyboard(PLAYER_ID_SHOW_NAME)
	end)
end

selectCreatorSidebar.onAbort = function()
	switch(nil, selectModeSidebar, MODE_PLAY, true)
end

selectCreatorSidebar.onSelected = function(creator)
	context.creator = creator
	switch(selectPuzzleScreen, selectPuzzleSidebar)
end

selectPuzzleSidebar.onAbort = function()
	switch(titleScreen, selectCreatorSidebar, context.creator.id, true)
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
		local puzzle = Puzzle.createEmpty()
		if context.player.sketch then
			local size = puzzle.width * puzzle.height
			local grid = table.create(size, 0)
			local values = {string.byte(context.player.sketch, 1, size)}
			for i = 1, size do
				grid[i] = values[i] - 48
			end
			puzzle.grid = grid
		end
		context.puzzle = puzzle
		switch(createPuzzleScreen, createPuzzleSidebar)
	elseif context.mode == MODE_SHARE then
		switch(nil, shareSidebar)
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

selectTutorialSidebar.onAbort = function()
	switch(nil, titleSidebar, ACTION_ID_TUTORIALS, true)
end

selectTutorialSidebar.onSketchTutorial = function()
	switch(sketchTutorialScreen, sketchTutorialSidebar)
end

selectTutorialSidebar.onSolveTutorial = function()
	switch(solveTutorialScreen, solveTutorialSidebar)
end

settingsSidebar.onAbort = function ()
	switch(nil, titleSidebar, ACTION_ID_SETTINGS, true)
end

settingsSidebar.onCrankSpeedDown = function ()
	context.settings.crankSpeed = (context.settings.crankSpeed + 3) % 5 + 1
	context.settings:save(context)
	switch(nil, settingsSidebar, ACTION_ID_CRANK_SPEED)
end

settingsSidebar.onCrankSpeedUp = function ()
	context.settings.crankSpeed = context.settings.crankSpeed % 5 + 1
	context.settings:save(context)
	switch(nil, settingsSidebar, ACTION_ID_CRANK_SPEED)
end

settingsSidebar.onDeletePuzzles = function ()
		switch(nil, deletePuzzlesSidebar)
end

settingsSidebar.onFontTypeToggle = function ()
	context.settings.fontType = context.settings.fontType % 2 + 1
	context.settings:save(context)
	fontText = context.settings.fontType == 1 and fontTextThin or fontTextBold
	switch(nil, context.sidebar, ACTION_ID_FONT_TYPE)
end

settingsSidebar.onHintStylePrevious = onHintStylePrevious
settingsSidebar.onHintStyleNext = onHintStyleNext
settingsSidebar.onMusicDown = onMusicDown
settingsSidebar.onMusicUp = onMusicUp
settingsSidebar.onEffectsDown = onEffectsDown
settingsSidebar.onEffectsUp = onEffectsUp

shareSidebar.onAbort = function ()
	switch(nil, selectModeSidebar, MODE_SHARE, true)
end

shareSidebar.onExportPuzzles = function ()
	local created = context.player.created
	local puzzles = table.create(0, #created)
	for i = 1, #created do
		local id = created[i]
		puzzles[id] = context.save.puzzles[id]
	end
	local profile = table.deepcopy(context.save.profiles[context.player.id])
	profile.played = nil
	profile.options = nil
	local time = playdate.getTime()
	profile.createdOn = string.format("%d-%02d-%02d", time.year, time.month, time.day)
	local export = {
		profileList = { context.player.id },
		profiles = {
			[context.player.id] = profile
		},
		puzzles = puzzles
	}
	local fileName = getFileNameForPlayer(context.player.name)
	playdate.datastore.write(export, DIR_EXPORT .. "/" .. fileName, true)
	showModal(
		"Your puzzles have been saved in the export folder in the file " .. fileName .. ".json.\n\n" ..
		"To share your puzzles with another player, copy the file to the import folder on their Playdate."
	)
end

sketchTutorialSidebar.onAbort = function ()
	switch(titleScreen, selectTutorialSidebar, ACTION_ID_SKETCH_TUTORIAL, true)
end

sketchTutorialSidebar.onHintStylePrevious = onHintStylePrevious
sketchTutorialSidebar.onHintStyleNext = onHintStyleNext

solveTutorialSidebar.onAbort = function ()
	switch(titleScreen, selectTutorialSidebar, ACTION_ID_SOLVE_TUTORIAL, true)
end

solveTutorialSidebar.onHintStylePrevious = onHintStylePrevious
solveTutorialSidebar.onHintStyleNext = onHintStyleNext

testPuzzleSidebar.onAbort = function ()
	switch(createPuzzleScreen, createPuzzleSidebar, nil, true)
end

testPuzzleSidebar.onHintStylePrevious = onHintStylePrevious
testPuzzleSidebar.onHintStyleNext = onHintStyleNext

testPuzzleSidebar.onResetGrid = function()
	context.screen:resetGrid()
	context.puzzle.hasBeenSolved = false
	switch(nil, testPuzzleSidebar, ACTION_ID_RESET_GRID)
end

testPuzzleSidebar.onRotatePuzzle = function ()
	context.puzzle:rotate(context)
	switch(solvedPuzzleScreen, testPuzzleSidebar, ACTION_ID_ROTATE, true)
end

testPuzzleSidebar.onSave = function ()
	switch(nil, namePuzzleSidebar, nil, nil, showPuzzleKeyboard)
end

testPuzzleSidebar.onUndo = function ()
	startUndo()
end

titleSidebar.onPlay = function ()
	switch(nil, selectPlayerSidebar)
end

titleSidebar.onSettings = function ()
	switch(nil, settingsSidebar)
end

titleSidebar.onTutorials = function ()
	switch(nil, selectTutorialSidebar)
end

titleSidebar.onAbout = function ()
	switch(aboutScreen, aboutSidebar)
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

playdate.file.mkdir(DIR_IMPORT)
playdate.file.mkdir(DIR_EXPORT)

context.ext = {}
local files <const> = playdate.file.listFiles(DIR_IMPORT)
for i = 1, #files do
	local name = files[i]
	if string.sub(name, -5, -1) == ".json" and string.sub(name, 0, 1) ~= "." then
		local id = string.sub(name, 0, -6)
		context.ext[id] = playdate.datastore.read(DIR_IMPORT .. "/" .. id)
		context.ext[id].id = id
	end
end

context.save = playdate.datastore.read(FILE_SAVE)
context.settings = Settings.load(context)
fontText = context.settings.fontType == FONT_TYPE_THIN and fontTextThin or fontTextBold

context.screen:enter(context)
context.sidebar:enter(context)
playdate.inputHandlers.push(defaultInputHandler)

openSidebar()
playdate.getSystemMenu():addOptionsMenuItem(
	"effects",
	AUDIO_LEVEL_NAMES,
	context.settings.effects,
	function (selected)
		updateEffectsSetting(AUDIO_LEVEL_NAMES_REVERSED[selected])
		if context.sidebar == settingsSidebar then
			switch(nil, context.sidebar, ACTION_ID_EFFECTS)
		end
	end
)
if MUSIC_ENABLED then
	playdate.getSystemMenu():addOptionsMenuItem(
		"music",
		AUDIO_LEVEL_NAMES,
		context.settings.music,
		function (selected)
			updateMusicSetting(AUDIO_LEVEL_NAMES_REVERSED[selected])
			if context.sidebar == settingsSidebar then
				switch(nil, context.sidebar, ACTION_ID_MUSIC)
			end
		end
	)
end

playTrack()

function playdate.update()
	context.screen:update()
	local inputHandler = playdate.inputHandlers[#playdate.inputHandlers]
	if inputHandler.update then
		inputHandler.update()
	end

	gfx.sprite.update()
	if
		playdate.keyboard.isVisible() or
		context.screen.cantIdle or
		playdate.buttonIsPressed(playdate.kButtonDown) or
		playdate.buttonIsPressed(playdate.kButtonUp)
	then
		idleCounter = 0
	else
		idleCounter += 1
		if idleCounter > 200 then
			if context.screen == createPuzzleScreen then
				context.player.sketch = table.concat(context.puzzle.grid)
				context.player:save(context)
			end
			playdate.stop()
		end
	end
	if context.undo and playdate.isCrankDocked() then
		playdate.ui.crankIndicator:update()
	end
	playdate.timer.updateTimers()
	playdate.frameTimer.updateTimers()
end

playdate.display.setRefreshRate(40)
