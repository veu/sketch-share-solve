-- music player
local snd = playdate.sound

MusicPlayer = {}

-- load songs into memory
local songs = {}
local song_list = {"none","retro","chiptune","classical", "electronic", "elektro", "elevator", "gameshow"}
songs["none"] = nil
songs["retro"] = snd.fileplayer.new('sound/songs/8-bit_chill', 3)
songs["chiptune"] = snd.fileplayer.new('sound/songs/chiptune', 3)
songs["classical"] = snd.fileplayer.new('sound/songs/classical', 3)
songs["electronic"] = snd.fileplayer.new('sound/songs/electronic', 3)
songs["elektro"] = snd.fileplayer.new('sound/songs/elektro', 3)
songs["elevator"] = snd.fileplayer.new('sound/songs/elevator', 3)
songs["gameshow"] = snd.fileplayer.new('sound/songs/gameshow', 3)

MusicPlayer.songs = songs

-- set song to play when game loads
local save_data = playdate.datastore.read(FILE_SAVE)
local song = save_data["song"] or "gameshow" -- load last used theme from saved game data
MusicPlayer.currentSong = song 
if MusicPlayer.currentSong ~= "none" then songs[MusicPlayer.currentSong]:play(0) end

-- plays song given as argument. If no argument is given then "currentSong" will be played
function MusicPlayer:playSong(name)
	-- if song name is specified, play specified song
	if self.songs[name] then
		self.songs[name]:play(0)
	else
		-- if song name NOT specified, play current song
		if self.currentSong ~= "none" then 
			if songs[self.currentSong] then
				songs[self.currentSong]:play(0) 
			else
				print("ERROR: song", name, "not found in dictionary")
			end
		end
	end
end


function MusicPlayer:stopSong(name)
	if name then 
		self.songs[name]:stop()
	else
		if self.currentSong ~= "none" then 
			self.songs[self.currentSong]:stop()
		end
	end
end


local sysMenu = playdate.getSystemMenu()
sysMenu:addOptionsMenuItem("music", song_list, MusicPlayer.currentSong,
	function(selected_song)
		if MusicPlayer.currentSong ~= "none" then MusicPlayer:stopSong(MusicPlayer.currentSong) end
		MusicPlayer.currentSong = selected_song
		
		if selected_song ~= "none" then MusicPlayer:playSong(MusicPlayer.currentSong) end

		-- save selected song to memory 
		save_data["song"] = MusicPlayer.currentSong
		playdate.datastore.write(save_data, FILE_SAVE, true)		

	end
)
