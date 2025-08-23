parser: y.tab.c lex.yy.c y.tab.h
	gcc -w -g y.tab.c lex.yy.c -ll -o parser
lex.yy.c: $(fname).l
	lex ${fname}.l
y.tab.c: $(fname).y
	yacc --debug -v -d -t --verbose ${fname}.y
clean: 
	rm -f parser y.tab.c y.tab.h lex.yy.c y.output