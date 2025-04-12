Mini C Compiler — CS304 Course Project
This project is a Mini C Compiler developed for the CS304 Compiler Construction course. The compiler covers the core four phases of compilation:

Phases Included
Lexical Analyzer

Syntax Analyzer

Semantic Analyzer

Intermediate Code Generator

How to Compile & Run
bash
Copy
Edit
yacc parser.y       # Run YACC on the parser file
lex lexer.l         # Run Lex on the lexer file
gcc lex.yy.c y.tab.c # Compile the generated C files
./a.out             # Run the compiled program
Description
A simple mini compiler for the C language that walks through the essential compiler phases — from tokenizing input to generating intermediate code.
