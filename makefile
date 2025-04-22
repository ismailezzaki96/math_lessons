
all:
	# cat presentation.md 1.md 2.md 3.md 4.md 5.md 6.md > index.md
	# pandoc_helper --preview --type presentation index.md
	pandoc_helper --preview --type html cours.md

