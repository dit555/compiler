parser:	comp.lex comp.y
	bison -v -d --file-prefix=y comp.y
	flex comp.lex
	gcc -o comp y.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c y.tab.* y.output *.o comp
