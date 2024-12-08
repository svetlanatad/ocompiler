all:
	voc -s scanner.Mod
	voc -m PARSER.Mod 
clean:
	rm *.h
	rm *.o
	rm *.c
