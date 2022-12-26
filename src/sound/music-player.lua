-- music player
local snd = playdate.sound

MusicPlayer = {}

-- load songs into memory
local songs = {}
local song_list = {"none","retro","chiptune","classical", "electronic", "elektro", "elevator", "gameshow"}
songs["none"] = nil
songs["retro"] = snd.fileplayer.new('sound/songs/8-bit_chill')
songs["chiptune"] = snd.fileplayer.new('sound/songs/chiptune')
songs["classical"] = snd.fileplayer.new('sound/songs/classical')
songs["electronic"] = snd.fileplayer.new('sound/songs/electronic')
songs["elektro"] = snd.fileplayer.new('sound/songs/elektro')
songs["elevator"] = snd.fileplayer.new('sound/songs/elevator')
songs["gameshow"] = snd.fileplayer.new('sound/songs/gameshow')

MusicPlayer.songs = songs

-- set song to play when game loads
local save_data = playdate.datastore.read(FILE_SAVE)
local song = save_data["song"] or "gameshow" -- load last used theme from saved game data
MusicPlayer.currentSong = song 
if MusicPlayer.currentSong ~= "none" then songs[MusicPlayer.currentSong]:play(0) end

-- plays song given as argument. If no argument is given then "currentSong" will be played
function MusicPlayer:playSong(name)
	if self.songs[name] then
		self.songs[name]:play(0)
	else
		if self.currentSong ~= "none" then songs[self.currentSong]:play(0) end
		--print("ERROR: song", name, "not found in dictionary")
	end
end


function MusicPlayer:stopSound(name)
	if name then 
		self.songs[name]:stop()
	else
		self.songs[self.currentSong]:stop()
	end
end


local sysMenu = playdate.getSystemMenu()
sysMenu:addOptionsMenuItem("music", song_list, MusicPlayer.currentSong,
	function(selected_song)
		if MusicPlayer.currentSong ~= "none" then MusicPlayer:stopSound(MusicPlayer.currentSong) end
		MusicPlayer.currentSong = selected_song
		
		if selected_song ~= "none" then MusicPlayer:playSong(MusicPlayer.currentSong) end

		-- save selected song to memory 
		save_data["song"] = MusicPlayer.currentSong
		playdate.datastore.write(save_data, FILE_SAVE, true)		

	end
)
