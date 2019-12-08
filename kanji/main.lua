require "Kanji"
require "TSerial"

function love.load()
	currentVersion = 0.22
	love.window.setTitle("Kyouiku Kanji 教育漢字 "..currentVersion)
	
	guiFont = love.graphics.newFont(8)
	levelFont = love.graphics.newFont(24)
	englishFont = love.graphics.newFont(48)
	kanjiFont = {love.graphics.newFont("dejima-mincho-r227.ttf", 128), love.graphics.newFont("chogokubosogothic_5.ttf", 128), love.graphics.newFont("KosugiMaru-Regular.ttf", 128)}
	hiraganaFont = love.graphics.newFont("07YasashisaAntique.ttf", 48)
	emptyBatchFont = love.graphics.newFont(128)
	
	kanjiID = 1
	kanjiCount = Kanji:load()
	
	data = {}
	if love.filesystem.getInfo("data.dat") ~= nil then
		data = TSerial.unpack(love.filesystem.read("string", "data.dat"))
	end
	if data.version == nil or data.version ~= currentVersion then
		data = {}
		data.version = currentVersion
	end
	if data.kanji == nil then
		data.kanji = {}
	end
	if data.batch == nil then
		data.batch = {kanji = {}, size = 5, index = 1, levels = {true, false, false, false, false}, repeats = 5, currentRepeats = 0, correct = 0}
	end
	for i=1,kanjiCount+1 do
		if data.kanji[i] == nil then
			data.kanji[i] = {c=1}
		end
	end
	if data.options == nil then
		data.options = {batchSize = 0.1, repeats = 0, kanjiFont = 1}
	end
	
	readKanji()
	
	info = false
	
	levelButtons = {}
	for i=-2,2 do
		levelButtons[#levelButtons+1] = {x = 1280/2+i*60, y=680, r=24, m=false}
	end
	
	guiButtons = {}
	guiButtons.incorrect = {x=1280/2-144,y=592,w=132,h=48,m=false,i=true}
	guiButtons.correct = {x=1280/2+12,y=592,w=132,h=48,m=false,i=true}
	guiButtons.resetBatch = {x=88,y=656,w=48,h=48,m=false,i=false}
	
	toggleLevelButtons = {}
	for i=0,4 do
		toggleLevelButtons[#toggleLevelButtons + 1] = {x=8+i*16, y=688, w=16, h=16, m=false, a=data.batch.levels[i+1]}
	end
	
	sliders = {}
	sliders.batchSize = {x=8, y=656, w=80, h=16, m=false, a=false, r=data.options.batchSize}
	sliders.repeats = {x=8, y=672, w=80, h=16, m=false, a=false, r=data.options.repeats}
	
	repeatImage = love.graphics.newImage("repeat.png")
	repeatCanvas = love.graphics.newCanvas(40,40,{msaa=16})
	love.graphics.setCanvas(repeatCanvas)
		love.graphics.draw(repeatImage, 0, 0, 0, 0.05, 0.05)
	love.graphics.setCanvas()
end

function save()
	love.filesystem.write("data.dat", TSerial.pack(data))
end

function circleCollision(x, y, c)
	if math.pow(x-c.x,2) + math.pow(y-c.y,2) <= math.pow(c.r,2) then
		return true
	else
		return false
	end
end

function rectangleCollision(x, y, r)
	if x >= r.x and x <= r.x+r.w and y >= r.y and y <= r.y+r.h then
		return true
	else
		return false
	end
end

function readKanji()
	if #data.batch.kanji > 0 then
		kanjiID = data.batch.kanji[data.batch.index].id
		kanji = Kanji.kanji[kanjiID]
	end
end

function shuffleBatch(batch)
  for i = #batch, 2, -1 do
    local j = math.random(i)
    batch[i], batch[j] = batch[j], batch[i]
  end
  return batch
end

function resetBatch()
	for k,v in pairs(levelButtons) do
		v.a = false
	end
	data.batch.kanji = {}
	data.batch.index = 1
	data.batch.currentRepeats = 0
	data.batch.correct = 0
	for kanjiID, kanji in ipairs(Kanji.kanji) do
		if data.batch.size > 0 and #data.batch.kanji >= data.batch.size then
			break
		end
		if data.batch.levels[data.kanji[kanjiID].c] == true then
			data.batch.kanji[#data.batch.kanji + 1] = {id=kanjiID, s=0}
		end
	end
	data.batch.kanji = shuffleBatch(data.batch.kanji)
	
	if #data.batch.kanji > 0 then
		readKanji()
	end
	info = false
end

function batchNextItem()
	local count = 0
	for k,v in ipairs(data.batch.kanji) do
		if v.s ~= data.batch.currentRepeats then
			count = count + 1
		end
	end
	data.batch.correct = count
	
	if data.batch.correct == #data.batch.kanji then
		data.batch.currentRepeats = data.batch.currentRepeats + 1
		if data.batch.repeats < 11 and data.batch.currentRepeats >= data.batch.repeats then
			data.batch.kanji = {}
		else
			data.batch.kanji = shuffleBatch(data.batch.kanji)
			data.batch.index = 1
			data.batch.correct = 0
		end
	else
		selectedKanji = false
		for k,v in ipairs(data.batch.kanji) do
			if data.batch.index < k and v.s == data.batch.currentRepeats then
				data.batch.index = k
				selectedKanji = true
				break
			end
		end
		if selectedKanji == false then
			for k,v in ipairs(data.batch.kanji) do
				if v.s == data.batch.currentRepeats then
					data.batch.index = k
					break
				end
			end
		end
	end
	
	readKanji()
end

function love.update(dt)
	if #data.batch.kanji == 0 then
		info = true
	end

	mx = love.mouse.getX()
	my = love.mouse.getY()
	
	for k,v in ipairs(levelButtons) do
		v.m = circleCollision(mx, my, v)
	end
	
	for k,v in ipairs(toggleLevelButtons) do
		v.m = rectangleCollision(mx, my, v)
	end
	
	for k,v in pairs(guiButtons) do
		v.m = rectangleCollision(mx, my, v)
	end
	
	for k,v in pairs(sliders) do
		v.m = rectangleCollision(mx, my, v)
	end
	
	if love.keyboard.isDown("escape") then
		save()
		love.event.quit()
	end
	
	for k,v in pairs(sliders) do
		if v.a == true then
			v.r = (mx-v.x)/v.w
			if v.r < 0 then
				v.r = 0
			elseif v.r > 1 then
				v.r = 1
			end
		end
	end
	data.batch.size = math.floor(sliders.batchSize.r*50)
	data.options.batchSize = sliders.batchSize.r
	data.batch.repeats = math.floor(sliders.repeats.r*11)
	data.options.repeats = sliders.repeats.r
end

function love.mousepressed(x, y, button, istouch, presses)
	if button == 1 then
		buttonPress = false
		for k,v in ipairs(levelButtons) do
			if v.m == true then
				buttonPress = true
				data.kanji[kanjiID].c = k
				if data.batch.levels[k] == false then
					for bk, bv in ipairs(data.batch.kanji) do
						if kanjiID == bv.id then
							table.remove(data.batch.kanji, bk)
							batchNextItem()
							break
						end
					end
				end
				save()
				return
			end
		end
		for k,v in pairs(guiButtons) do
			if v.m == true then
				if k == "resetBatch" then
					buttonPress = true
					resetBatch()
					return
				elseif k == "correct" and info == true and #data.batch.kanji > 0 then
					info = false
					data.batch.kanji[data.batch.index].s = data.batch.kanji[data.batch.index].s + 1
					batchNextItem()
					return
				elseif k == "incorrect" and info == true and #data.batch.kanji > 0 then
					info = false
					batchNextItem()
					return
				end
			end
		end
			for k,v in ipairs(toggleLevelButtons) do
			if v.m == true then
				buttonPress = true
				v.a = not v.a
				data.batch.levels[k] = v.a
				save()
				return
			end
		end
		for k,v in pairs(sliders) do
			if v.m == true then
				buttonPress = true
				v.a = true
				return
			end
		end
		if info == false and buttonPress == false then
			info = true
		end
		if info == true and #data.batch.kanji == 0 then
			resetBatch()
		end
	elseif button == 2 and info == false then
		batchNextItem()
	elseif button == 3 then
		data.options.kanjiFont = data.options.kanjiFont%#kanjiFont + 1
	end
end

function love.mousereleased(x, y, button, itouch)
	for k,v in pairs(sliders) do
		if v.a == true then
			v.a = false
			save()
		end
	end
end

function love.draw()
	local batchSize = #data.batch.kanji
	love.graphics.clear(0.91, 0.91, 0.91)
	if batchSize > 0 then
		love.graphics.setColor(0, 0.64, 0.88)
		love.graphics.rectangle("fill", 0, 0, 1280, 300)
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(kanjiFont[data.options.kanjiFont])
		love.graphics.print(kanji.kanji, 590, 80)
	else
		love.graphics.setColor(1, 0.05, 0.3)
		love.graphics.rectangle("fill", 0, 0, 1280, 300)
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(emptyBatchFont)
		love.graphics.print("Batch Empty!",220,80)
	end
	love.graphics.setColor(0.2, 0.2, 0.2)
	love.graphics.setFont(guiFont)
	local batchSizeString = data.batch.size
	if batchSizeString == 0 then
		batchSizeString = "∞"
	end
	local repeatsString = data.batch.repeats
	if repeatsString == 11 then
		repeatsString = "∞"
	end
	love.graphics.print("ID: " .. kanjiID .. " Batch Size: " .. batchSizeString .. " Repeats: " .. data.batch.currentRepeats .. "/" .. repeatsString .. " Correct: " .. data.batch.correct .. "/" .. #data.batch.kanji, 8, 708)
	love.graphics.print("Version "..currentVersion.." ~ Design by tsuneko", 1140, 708)
	
	if batchSize > 0 then
		love.graphics.setFont(levelFont)
		for k,v in ipairs(levelButtons) do
			if v.m == true then
				love.graphics.setColor(0.5, 0.5, 0.5)
			else
				love.graphics.setColor(0.7, 0.7, 0.7)
			end
			love.graphics.circle("fill", v.x, v.y, v.r)
			if data.kanji[kanjiID].c == k then
				love.graphics.setColor(0.2, 0.2, 0.2)
			end
			love.graphics.circle("line", v.x, v.y, v.r)
			love.graphics.setColor(0.2, 0.2, 0.2)
			love.graphics.print(k, v.x-v.r/3.5, v.y-v.r/1.75)
		end
	end
	
	for k,v in ipairs(toggleLevelButtons) do
		if v.m == true then
			love.graphics.setColor(0.5, 0.5, 0.5)
		elseif v.a == true then
			love.graphics.setColor(0.2, 0.2, 0.2)
		else
			love.graphics.setColor(0.7, 0.7, 0.7)
		end
		love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
	end
	
	for k,v in pairs(sliders) do
		if v.m == true then
			love.graphics.setColor(0.5, 0.5, 0.5)
		else
			love.graphics.setColor(0.7, 0.7, 0.7)
		end
		love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
		love.graphics.setColor(0.2, 0.2, 0.2)
		love.graphics.line(v.x + v.w * v.r, v.y, v.x + v.w * v.r, v.y+v.h)
	end
	
	for k,v in pairs(guiButtons) do
		if v.i == false or (info == true and batchSize > 0) then
			if v.m == true then
				love.graphics.setColor(0.5, 0.5, 0.5)
			else
				love.graphics.setColor(0.7, 0.7, 0.7)
			end
			love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
			if v.t == true and v.a == true then
				love.graphics.setColor(0.2, 0.2, 0.2)
				love.graphics.rectangle("line", v.x, v.y, v.w, v.h)
			end
		end
	end
	love.graphics.setBlendMode("add")
	love.graphics.draw(repeatCanvas, guiButtons.resetBatch.x+4, guiButtons.resetBatch.y+4)
	love.graphics.setBlendMode("alpha")
		
	if info == true and batchSize > 0 then
		love.graphics.setColor(0.2, 0.2, 0.2)
		love.graphics.setFont(englishFont)
		love.graphics.print("On'yomi", 48, 348)
		love.graphics.print("Kun'yomi", 48, 416)
		love.graphics.print("Meaning", 48, 488)
		love.graphics.print(kanji.meaning, 300, 488)
		love.graphics.setFont(hiraganaFont)
		love.graphics.print(kanji.onyomi, 300, 348)
		love.graphics.print(kanji.kunyomi, 300, 416)
		love.graphics.setFont(levelFont)
		love.graphics.setColor(0.2, 0.2, 0.2)
		love.graphics.print("Incorrect", guiButtons.incorrect.x+13, guiButtons.incorrect.y+10)
		love.graphics.print("Correct", guiButtons.correct.x+21, guiButtons.correct.y+10)
	end
end