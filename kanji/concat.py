lines = []
for i in range(6):
    f = open("kanji"+str(i+1)+".txt", encoding="utf-8")
    lines += list(map(lambda x:x.rstrip(),f.readlines()))
    f.close()
f = open("kanji.txt", "w", encoding="utf-8")
for l in lines:
    f.write(l + "\n")
f.close()
print("Done.")
