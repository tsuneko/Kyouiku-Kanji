# Kyouiku-Kanji

Simple flashcard app for G1~G6 Kanji built on the Love2D Game Engine. I only spent a day working on this, so it may have bugs.

Kanji data is parsed from the list found on [this site](https://agreatdream.com/japanese-ministry-of-education-list-of-kanji-by-school-year-okm/). There may be issues with the data parsed, as well as the romaji to hiragana conversion. Please do not rely on this application for thorough learning, its primary intention is for revision of material already learnt.

## Features:
- 1006 Kanji
- Automatically saved progress and state
- Set system which can be used to move learnt Kanji up sets as they are learnt. It is recommended to have Set 1 for unknown Kanji, Set 2~4 for currently learning Kanji and Set 5 for learnt Kanji.
- Batch system which can be sized between 1 and 50 Kanji, as well as an infinite option. The infinite option should be used for revising a whole Set, and as such it is not recommended to use it for Set 1.
- To specify which Kanji of Sets are loaded into the batch, there are five square toggle buttons on the bottom left.
- Marking system which requires all items in a batch to be marked as correct for the batch to complete.
- Repeat system which allows a batch to be repeated between 0 to 10 times, or infinitely. The infinite option should be used for cram practice.

## FAQ
- Empty batch? - This means that you need to reset the batch because it has either been completed, or that there are no Kanji in the selected Sets. To select which Sets to study, please use the five square toggle buttons on the bottom left. To reset the batch, either click in the middle of the screen, or click the reset icon.
- Can Kanji be skipped? - Yes, with right click, assuming that the flashcard is not flipped.
- How is the Kanji ordered? - The Kanji is ordered from Joyo grades, and this order is used when populating a batch with Kanji.
- There is incorrect text, or text which goes off the screen? - This is an issue with the format of the Kanji list, and could be corrected in the future with an update to the parsing code. Please create an Issue with the Kanji ID listed on the bottom left.

## Screenshots:

![Flipped Flashcard](ss.png)

## (Terribly Drawn) Explanation of UI

![Help Image](HELP.png)
