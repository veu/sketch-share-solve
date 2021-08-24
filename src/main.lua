import "imports"

-- screens
local createAvatarScreen = CreateAvatarScreen()
local createPuzzleScreen = CreatePuzzleScreen()
local solvedPuzzleScreen = SolvedPuzzleScreen()
local playPuzzleScreen = PlayPuzzleScreen()
local titleScreen = TitleScreen()
local tutorialScreen = TutorialScreen()

-- sidebars
local createAvatarSidebar = CreateAvatarSidebar()
local createPuzzleSidebar = CreatePuzzleSidebar()
local namePlayerSidebar = SelectPlayerSidebar()
local namePuzzleSidebar = NamePuzzleSidebar()
local optionsSidebar = OptionsSidebar()
local playPuzzleSidebar = PlayPuzzleSidebar()
local selectAvatarSidebar = SelectAvatarSidebar()
local selectCreatorSidebar = SelectCreatorSidebar()
local selectPuzzleSidebar = SelectPuzzleSidebar()
local selectPlayerSidebar = SelectPlayerSidebar()
local selectModeSidebar = SelectModeSidebar()
local selectTutorialSidebar = SelectTutorialSidebar()
local settingsSidebar = SettingsSidebar()
local shareSidebar = ShareSidebar()
local testPuzzleSidebar = TestPuzzleSidebar()
local titleSidebar = TitleSidebar()
local tutorialSidebar = TutorialSidebar()

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
	isSidebarOpen = false,
}

local defaultInputHandler = createDefaultInputHandler(context)
local modalInputHandler = createModalInputHandler(context)
local noopInputHandler = createNoopInputHandler(context)

local openMenuItem = nil

function openSidebar()
	if not context.isSidebarOpen then
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
	local invalid = #context.puzzle.title == 0

	playdate.keyboard.keyboardWillHideCallback = function ()
		if invalid then
			switch(solvedPuzzleScreen, testPuzzleSidebar, nil, true)
		else
			context.player.sketch = nil
			context.player:save(context)
			context.puzzle:save(context)

			context.creator = context.player
			context.mode = MODE_PLAY
			switch(titleScreen, selectPuzzleSidebar, context.puzzle.id, true)
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
			switch(nil, namePuzzleSidebar)
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
	context.player.sketch = table.concat(context.puzzle.grid)
	context.player:save(context)
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
	context.player.sketch = table.concat(context.puzzle.grid)
	context.player:save(context)
	switch(nil, createPuzzleSidebar, ACTION_ID_FLIP)
end

createPuzzleSidebar.onInvertColors = function()
	context.screen:invertGrid()
	context.puzzle.hasBeenSolved = false
	context.player.sketch = table.concat(context.puzzle.grid)
	context.player:save(context)
	switch(nil, createPuzzleSidebar, ACTION_ID_INVERT_COLORS)
end

createPuzzleSidebar.onResetGrid = function()
	context.screen:resetGrid()
	context.puzzle.hasBeenSolved = false
	context.player.sketch = table.concat(context.puzzle.grid)
	context.player:save(context)
	switch(nil, createPuzzleSidebar, ACTION_ID_RESET_GRID)
end

createPuzzleSidebar.onTestAndSave = function ()
	if context.puzzle.hasBeenSolved then
		switch(solvedPuzzleScreen, testPuzzleSidebar)
	else
		switch(playPuzzleScreen, testPuzzleSidebar)
	end
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
		showModal("Deleting your profile will delete your created puzzles as well. Continue anyway?", "Delete")
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
	puzzle.hasBeenSolved = true
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

selectTutorialSidebar.onSolveTutorial = function()
	switch(tutorialScreen, tutorialSidebar)
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

shareSidebar.onAbort = function ()
	switch(nil, selectModeSidebar, MODE_SHARE, true)
end

shareSidebar.onExportPuzzles = function ()
	local puzzles = table.create(0, #context.player.created)
	for i, id in ipairs(context.player.created) do
		puzzles[id] = context.save.puzzles[id]
	end
	local profile = table.deepcopy(context.save.profiles[context.player.id])
	profile.played = nil
	profile.options = nil
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
		"Your puzzles have been saved in the export folder in the " .. fileName .. ".json file.\n\n" ..
		"To share your puzzles with another player, put the file in the import directory on their Playdate."
	)
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
	switch(nil, namePuzzleSidebar)
	showPuzzleKeyboard()
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

titleSidebar.onQuickPlay = function ()
	context.player = Profile.load(context, PLAYER_ID_QUICK_PLAY)
	context.creator = Profile.load(context, PLAYER_ID_RDK, context.ext.rdk)
	local puzzleId = context.creator.created[math.random(#context.creator.created)]
	context.puzzle = Puzzle.load(context, puzzleId, context.ext.rdk)
	context.mode = MODE_PLAY
	switch(playPuzzleScreen, playPuzzleSidebar)
end

tutorialSidebar.onAbort = function ()
	switch(titleScreen, selectTutorialSidebar, nil, true)
end

math.randomseed(playdate.getSecondsSinceEpoch())

function save(context)
	playdate.datastore.write(context.save, FILE_SAVE, true)
end

playdate.file.mkdir(DIR_IMPORT)
playdate.file.mkdir(DIR_EXPORT)

context.ext = {}
for i, name in ipairs(playdate.file.listFiles(DIR_IMPORT)) do
	if string.sub(name, -5, -1) == ".json" and string.sub(name, 0, 1) ~= "." then
		local id = string.sub(name, 0, -6)
		context.ext[id] = playdate.datastore.read(DIR_IMPORT .. "/" .. id)
		context.ext[id].id = id
	end
end

context.save = playdate.datastore.read(FILE_SAVE)
context.settings = Settings.load(context)

context.screen:enter(context)
context.sidebar:enter(context)
playdate.inputHandlers.push(defaultInputHandler)

openSidebar()

local showFPS = false
-- local menuItem = playdate.getSystemMenu():addMenuItem("toggle fps", function()
-- 	showFPS = not showFPS
-- end)

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
