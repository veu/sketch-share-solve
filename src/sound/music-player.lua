-- music player
local snd = playdate.sound

-- load songs into memory
local songs = {}
local song_list = {"none","retro","chiptune","classical", "electronic", "elektro", "elevator", "gameshow"}
songs["none"] = nil
songs["retro"] = snd.fileplayer.new('sound/8-bit_chill')
songs["chiptune"] = snd.fileplayer.new('sound/chiptune')
songs["classical"] = snd.fileplayer.new('sound/classical')
songs["electronic"] = snd.fileplayer.new('sound/electronic')
songs["elektro"] = snd.fileplayer.new('sound/elektro')
songs["elevator"] = snd.fileplayer.new('sound/elevator')
songs["gameshow"] = snd.fileplayer.new('sound/gameshow')

-- set song to play when game loads
local save_data = playdate.datastore.read(FILE_SAVE)
local song = save_data["song"] or "gameshow" -- load last used theme from saved game data
local currentSong = song 

if currentSong ~= "none" then songs[currentSong]:play(0) end

local sysMenu = playdate.getSystemMenu()
sysMenu:addOptionsMenuItem("music", song_list, currentSong,
	function(selected_song)
		if currentSong ~= "none" then songs[currentSong]:stop() end
		currentSong = selected_song
		
		if selected_song ~= "none" then songs[currentSong]:play(0) end

		-- save selected song to memory 
		save_data["song"] = currentSong
		playdate.datastore.write(save_data, FILE_SAVE, true)		

	end
)
