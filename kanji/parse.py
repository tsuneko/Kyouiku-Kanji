hiragana = []
r = open("hiragana.txt", encoding="utf-8")
for l in r.readlines():
	hiragana.append(l.rstrip().split(","))
r.close()

p = open("kanjiparsed.txt", "w", encoding="utf-8")

f = open("kanji.txt",  encoding="utf-8")
for l in f.readlines():
	ln = l.split("\t")
	for i in range(len(ln)):
		ln[i] = ln[i].replace(" or ",";").replace("; ",";").replace("(connects to other words)","~").replace(" –","").rstrip()
		if i == 1 or i == 2:
			for h in hiragana:
				ln[i] = ln[i].replace(h[0], h[1])
		p.write(ln[i] + "\n")
f.close()
p.close()

print("Done.")

