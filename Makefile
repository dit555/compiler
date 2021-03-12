parser:	comp.lex comp.y
	bison -v -d --file-prefix=y comp.y
	flex comp.lex
	gcc -o comp y.tab.c lex.yy.c -lfl

run:    comp.lex comp.y
	bison -v -d --file-prefix=y comp.y
	flex comp.lex
	gcc -o comp y.tab.c lex.yy.c -lfl
	./comp test.txt > comp.mil
	mil_run comp.mil < input.txt



clean:
	rm -f lex.yy.c y.tab.* y.output *.o comp *.mil
