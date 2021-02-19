flex:
	flex comp.lex
	gcc -o comp lex.yy.c -lfl

bison:	comp.lex comp.y
	bison -v -d --file-prefix=y comp.y
	flex comp.lex
	gcc -o comp y.tab.c lex.yy.c -lfl

run:
	flex comp.lex
	gcc -o comp lex.yy.c -lfl
	./comp tfile.txt > token.txt
clean:
	rm -f lex.yy.c y.tab.* y.output *.o comp
