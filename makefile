vlang.exe: lex.yy.c vlang.tab.c
	gcc lex.yy.c vlang.tab.c -o vlang.exe
	type input.txt | .\vlang.exe >output.txt
	
lex.yy.c: vlang.tab.c vlang.l
	flex vlang.l

vlang.tab.c: vlang.y
	bison -d vlang.y

clean: 
	del lex.yy.c vlang.tab.c vlang.tab.h vlang.exe