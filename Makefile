mycompiler: lexer
	gcc -o mycompiler lex.yy.c myYungParser.tab.c cgen.c -lfl

lexer: parser
	flex myYungFlex.l

parser:
	bison -d -v -r all myYungParser.y

clean:
	rm lex.yy.c\
		myYungParser.output\
		myYungParser.tab.c\
		myYungParser.tab.h\
		mycompiler