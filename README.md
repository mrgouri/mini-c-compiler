# Mini C Compiler 

This project is a **Mini C Compiler** developed for the **CS304 Compiler Design** course. The compiler covers the core four phases of compilation:

## Phases Included

1. **Lexical Analyzer**  
2. **Syntax Analyzer**  
3. **Semantic Analyzer**  
4. **Intermediate Code Generator**  

## How to Compile & Run

```bash
yacc parser.y       # Run YACC on the parser file
lex lexer.l         # Run Lex on the lexer file
gcc lex.yy.c y.tab.c # Compile the generated C files
./a.out             # Run the compiled program
