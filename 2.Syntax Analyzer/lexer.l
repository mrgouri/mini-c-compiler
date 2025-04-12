%option yylineno
 /* Declaration of variables and functions */
%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"
int flag;

typedef struct node {
    char *key;
    char *value;
    struct node *next;
} token_const;

token *constant_head = NULL;

void addConstant(char* tok, char* type);

%}
 /* Regular definitions */
num [0-9]
alpha [a-zA-Z]
alphanum {alpha}|{num}
escape_sequences \\(0|a|b|f|n|r|t|v|"\\"|"\""|')
ws [ \t\r\f\v]+
%x ML
 /* Pattern Matching Rules */
%%
\n { }
"#include"[ ]*"<"{alpha}({alphanum})*".h>" { }
"#define"[ ]+(_|{alpha})({alphanum})*[ ]*(.)+ { }
"//".* { }
"/*"([^*]|\*+[^*/])*\*+"/" { }
"["|"]"|"("|")"|"{"|"}"|","|";"|":"|"." {return *yytext;}
"->"|"+"|"-"|"*"|"/"|"="|"%"|"&"|"^"|","|";"|":"|"?" { return *yytext; }
"++"|"--" { return INC_DEC; }
"!" { return NOT; }
"+="|"-="|"*="|"/="|"%=" { return OP_EQUAL; }
"&&"|"||" { return LOG; }
">="|"<="|">"|"<"|"=="|"!=" { return REL; }
"int" { return INT; }
"char"|"double"|"float"|"void" { return DATA_TYPE; }
"long"|"short" { return SIZE_MODIFIER; }
"signed"|"unsigned" { return SIGN; }
"const"|"register"|"static"|"auto"|"extern" { return SCOPE; }
"if" { return IF; }
"else" { return ELSE; }
"for" { return FOR; }
"while" { return WHILE; }
"do" { return DO; }
"NULL" {return NULL;}
"struct"|"union" { return STRUCT_UNION; }
"return" { return RETURN; }
"sizeof" { return SIZEOF; }
"break" { return BREAK; }
"continue" { return CONTINUE; }
"goto" { return GOTO; }
"switch" { return SWITCH; }
"case" { return CASE; }
"default" { return DEFAULT; }
("\"")[^\n\"]*("\"") { addConstant(yytext,"String"); return STR_CONST; }
("\"")[^\n\"]* {
printf("Line No. %d ERROR: UNCLOSED STRING-%s\n", yylineno, yytext);
return 0;
}
("\'")({escape_sequences}|.)("\'") { addConstant(yytext,"Char"); return CHAR_CONST; }
("\'")(((("\\")[^0abfnrtv\\\"\'][^\n\']*))|[^\n\''][^\n\'']+)("\'") {
printf("Line No. %d ERROR: NOT A CHARACTER-%s\n", yylineno, yytext);
return 0;
}
[+-]?{num}*[.]{num}+ { addConstant(yytext, "Float"); return FLOAT_CONST; }
[+-]?{num}*[.]?{num}+[eE][+-]?{num}*[.]?{num}+ { addConstant(yytext, "Float"); return FLOAT_CONST; }
{num}+ { addConstant(yytext, "Integer"); return INT_CONST; }
(_|{alpha})({alphanum}|_)* { return ID; }
(_|{alpha})({alphanum}|_)*/\[ { return ID; }
{ws} {}
. {
flag = 1;
if(yytext[0] == '#')
printf("Line No. %d PREPROCESSOR ERROR-%s\n", yylineno, yytext);
else
printf("Line No. %d ERROR ILLEGAL CHARACTER-%s\n", yylineno, yytext);
return 0;
}
%%

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

int yywrap() {
return 1;
}