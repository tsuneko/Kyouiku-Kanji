Kanji = {}
Kanji.kanji = {}

function Kanji:load(input)
	lines = {}
	lineIndex = 0
	for line in love.filesystem.lines("kanjiparsed.txt") do
		if lineIndex == 0 then
			Kanji.kanji[#Kanji.kanji + 1] = {}
			Kanji.kanji[#Kanji.kanji].kanji = line
		elseif lineIndex == 1 then
			Kanji.kanji[#Kanji.kanji].onyomi = line
		elseif lineIndex == 2 then
			Kanji.kanji[#Kanji.kanji].kunyomi = line
		elseif lineIndex == 3 then
			Kanji.kanji[#Kanji.kanji].meaning = line
		end
		lineIndex = (lineIndex + 1)%4
	end
	return #Kanji.kanji
end