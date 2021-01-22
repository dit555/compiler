parse:
	flex comp.lex
	gcc -o comp lex.yy.c -lfl

run:
	flex comp.lex
	gcc -o comp lex.yy.c -lfl
	./comp tfile.txt > token.txt
clean:
	rm -f lex.yy.c y.tab.* y.output *.o comp
