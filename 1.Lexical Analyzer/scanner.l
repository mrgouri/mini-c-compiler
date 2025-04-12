%option yylineno noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int total = 0;
int comment_depth = 0;  // Counter for nested comments
int comment_start_line = 0;  // Line where the comment starts
int string_start_line = 0;  // Line where the string starts

typedef struct node {
    char *key;
    char *value;
    struct node *next;
} token;

token *symbol_head = NULL;
token *constant_head = NULL;

void addSymbol(char* tok, char* type);
void addConstant(char* tok, char* type);

%}

%x SC_COMMENT 
%x SC_STRING

%%

 int comment_nesting = 0;
#.* { 
    total++; 
    fprintf(yyout, "This is Pre-processor directive: %s\n\n", yytext);
}

[',;'(){}._] { 
    total++; 
    fprintf(yyout, "This is Delimiter: %s\n\n", yytext);
    addSymbol(yytext, "Delimiter");
}

"#"|"@"|"$"|"^"|"%"|"&" { 
    total++; 
    fprintf(yyout, "This is Special Character: %s\n\n", yytext);
    addSymbol(yytext, "Special Character");
}

"=" { 
    total++; 
    fprintf(yyout, "This is Assignment Operator: %s\n\n", yytext);
    addSymbol(yytext, "Assignment Operator");
}

"&&"|"||" { 
    total++; 
    fprintf(yyout, "This is Logical Operator: %s\n\n", yytext);
    addSymbol(yytext, "Logical Operator");
}

"+"|"-"|"*"|"/" { 
    total++; 
    fprintf(yyout, "This is Arithmetic Operator: %s\n\n", yytext);
    addSymbol(yytext, "Arithmetic Operator");
}

"++"|"--" { 
    total++; 
    fprintf(yyout, "This is Increment/Decrement Operator: %s\n\n", yytext);
    addSymbol(yytext, "Increment/Decrement Operator");
}

"<="|">="|"!="|"=="|"<"|">" { 
    total++; 
    fprintf(yyout, "This is Relational Operator: %s\n\n", yytext);
    addSymbol(yytext, "Relational Operator");
}

"int"|"if"|"else"|"while"|"do"|"break"|"continue"|"double"|"float"|"return"|"EOF"|"char"|"case"|"sizeof"|"long"|"short"|"typedef"|"switch"|"unsigned"|"void"|"static"|"struct"|"goto"|"main" { 
    total++; 
    fprintf(yyout, "This is Keyword: %s\n\n", yytext);
    addSymbol(yytext, "Keyword");
}

[a-zA-Z_][a-zA-Z0-9_]*\( { 
    total++; 
    fprintf(yyout, "This is Function: %s\n\n", yytext);
    yytext[strlen(yytext) - 1] = '\0';
    addSymbol(yytext, "Function");
}

[a-zA-Z_][a-zA-Z0-9_]* { 
    total++; 
    fprintf(yyout, "This is Identifier: %s\n\n", yytext);
    addSymbol(yytext, "Identifier");
}

[0-9]+\.[0-9]+ { 
    total++; 
    fprintf(yyout, "This is Fraction: %s\n\n", yytext);
    
} 

-[0-9]+\.[0-9]+ { 
    total++; 
    fprintf(yyout, "This is Negative Fraction: %s\n\n", yytext);
    addConstant(yytext, "Float");
} 

[0-9]+ { 
    total++; 
    fprintf(yyout, "This is Integer: %s\n\n", yytext);
    addConstant(yytext, "Integer");
}

-[0-9]+ { 
    total++; 
    fprintf(yyout, "This is Negative Integer: %s\n\n", yytext);
    addConstant(yytext, "Integer");
}

(\")([^\"\\\n]|\\.|\\\n)*["] {total++; fprintf(yyout,"this is String:%s\n\n",yytext);
addConstant(yytext,"String");
}

"//".*    { 
    total++; 
    fprintf(yyout, "This is single-line Comment: %s\n\n", yytext); 
}

"/*"    { 
    BEGIN(SC_COMMENT);
    comment_depth = 1;
    comment_start_line = yylineno;
    fprintf(yyout, "Start of multi-line comment: %s", yytext);
}

<SC_COMMENT>{
    "/*"    { 
        comment_depth++; 
        fprintf(yyout, "%s", yytext);
    }
    "*/"    { 
        comment_depth--; 
        fprintf(yyout, "%s", yytext);
        if (comment_depth == 0) {
            fprintf(yyout, "\nEnd of multi-line comment\n\n");
            BEGIN(INITIAL);
        }
    }
    .|\n    { fprintf(yyout, "%s", yytext); }
    <<EOF>> {
        fprintf(yyout, "\nERROR: Unclosed comment starting at line %d\n", comment_start_line);
        yyterminate();
    }
}

("\"")[^\n\"]* {
 fprintf(yyout,"Line No. %d ERROR: UNCLOSED STRING-%s\n", yylineno, yytext);
 yyterminate();
 }

[\t\n ]+ { }

. { 
    fprintf(yyout, "Line No. %d ERROR: ILLEGAL TOKEN - %s\n", yylineno, yytext);
yyterminate();
}

%%


void addSymbol(char* tok, char* type) {
    if(symbol_head == NULL) {
        token* new_node = (token*)malloc(sizeof(token));
        new_node->next = NULL;
        new_node->value = strdup(type);
        new_node->key = strdup(tok);
        symbol_head = new_node;
        return;
    }
    token *cur = symbol_head;
    token *prev = NULL;
    while(cur != NULL) {
        if(strcmp(cur->key, tok) == 0) return;
        prev = cur;
        cur = cur->next;
    }
    token* new_node = (token*)malloc(sizeof(token));
    new_node->next = NULL;
    new_node->value = strdup(type);
    new_node->key = strdup(tok);
    prev->next = new_node;
}

void addConstant(char* tok, char* type) {
    if(constant_head == NULL) {
        token* new_node = (token*)malloc(sizeof(token));
        new_node->next = NULL;
        new_node->value = strdup(type);
        new_node->key = strdup(tok);
        constant_head = new_node;
        return;
    }
    token *cur = constant_head;
    token *prev = NULL;
    while(cur != NULL) {
        if(strcmp(cur->key, tok) == 0) return;
        prev = cur;
        cur = cur->next;
    }
    token* new_node = (token*)malloc(sizeof(token));
    new_node->next = NULL;
    new_node->value = strdup(type);
    new_node->key = strdup(tok);
    prev->next = new_node;
}

int main() {
    extern FILE *yyin, *yyout; 

    yyin = fopen("input(error4).txt", "r"); 
    yyout = fopen("Output(error4).txt", "w"); 

    yylex();

    fprintf(yyout, "\n\n\n\n Total Tokens = %d \n\n\n", total);

    // Printing the symbol table
    token* cur = symbol_head;
    fprintf(yyout, "SYMBOL TABLE\n");
    fprintf(yyout, "%-20s %-20s\n", "     SYMBOL", "      TYPE");
    fprintf(yyout, "%-20s %-20s\n", "-------------------", "-------------------");
    while(cur != NULL) {
        fprintf(yyout, "%-20s %-20s\n", cur->key, cur->value);
        fprintf(yyout, "%-20s %-20s\n", "-------------------", "-------------------");
        cur = cur->next;
    }

    fprintf(yyout,"\n\n");

    // Printing the constant table
    cur = constant_head;
    fprintf(yyout, "CONSTANT TABLE\n");
    fprintf(yyout, "%-20s %-20s\n", "     CONSTANT", "      TYPE");
    fprintf(yyout, "%-20s %-20s\n", "-------------------", "-------------------");
    while(cur != NULL) {
        fprintf(yyout, "%-20s %-20s\n", cur->key, cur->value);
        fprintf(yyout, "%-20s %-20s\n", "-------------------", "-------------------");
        cur = cur->next;
    }

    fclose(yyin);
    fclose(yyout);

    return 0; 
}