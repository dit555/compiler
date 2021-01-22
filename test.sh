echo "running flex"
flex comp.lex
echo "running gcc"
gcc lex.yy.c -lfl
echo "tokinizing"
./a.out tfile.txt > token.txt
echo "done"
