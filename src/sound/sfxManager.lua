local snd = playdate.sound

sfxManager = {}

local sfx_files = playdate.file.listFiles("sound/sfx/")
local sounds = {}

-- traversing list of files in sfx files and generating dictionary of sound effects
for _, file_name in pairs(sfx_files) do
    sound_name = string.gsub(file_name, ".pda", "") -- removing extension
    sounds[sound_name] = snd.sampleplayer.new("sound/sfx/" .. sound_name)
end

sfxManager.sounds = sounds

function sfxManager:playSound(name)
    if self.sounds[name] then
        self.sounds[name]:play(1)
    else
        print("ERROR: sound", name, "not found in dictionary")
    end
end

-- plays a song then calls callback function
function sfxManager:playWithCallback(name, func, ...)
    if self.sounds[name] then
        if func then self.sounds[name]:setFinishCallback(func, ...) end
        self.sounds[name]:play(1)
    else
        print("ERROR: sound", name, "not found in dictionary")
    end
end

function sfxManager:stopSound(name)
    self.sounds[name]:stop()
end