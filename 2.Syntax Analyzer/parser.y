%{
 #include "stdio.h"
 #include "stdlib.h"
 #include "ctype.h"
 #include "string.h"

typedef struct node {
    char *key;
    char *value;
    struct node *next;
} token;
 
 extern int flag;
 extern token *constant_head;


 int arr_dim = 1;
 int yyerror();
 int yylex();
 
 %}
 %token INT DATA_TYPE SIZE_MODIFIER SIGN SCOPE STRUCT_UNION
 %token RETURN MAIN
 %token WHILE FOR DO
 %token BREAK CONTINUE GOTO
 %token ENDIF
 %token SWITCH CASE DEFAULT
 %token IF ELSE
 %token ID
 %token INT_CONST STR_CONST FLOAT_CONST CHAR_CONST
 %right OP_EQUAL
 %right '='
%left LOG
 %left '^'
 %left REL
 %left '+' '-'
 %left '*' '/' '%'
 %right SIZEOF
 %right NOT
 %left INC_DEC
 %expect 3
 %start S
 %%
 S: content ;
 content: declaration content | ;
 declaration: variable_declaration
 | function_declaration
 | struct_dec;
 struct_dec: STRUCT_UNION ID '{' struct_body '}' ';';
 struct_body: variable_declaration struct_body
 | ;
 variable_declaration: datatype var ';'
 | struct_initialise ;
 struct_initialise: STRUCT_UNION ID var 
 |STRUCT_UNION ID star var;
 var: id_name
 | id_name ',' var ;
 id_name: ID extended_id;
 extended_id: arr_id
 | '=' exp
 | ;

arr_id: '[' INT_CONST ']' initialise {arr_dim *= atoi(*yytext);
//add to table
arr_dim = 1;
}
 | '[' INT_CONST ']' arr_id    {arr_dim *= atoi(*yytext);};
 
initialise: string_initialise
 | arr_initialise
 | ;
 string_initialise: '=' STR_CONST;
 arr_initialise: '=' multi_dim;
 multi_dim: '{' arr_elements '}';
 arr_elements: arr_values
 | '{' arr_values '}'
 | multi_dim
 | multi_dim ',' '{' arr_elements '}'
 | '{' arr_values '}' ',' arr_elements ;
 arr_values: constant multiple_arr_values;
 multiple_arr_values: ',' arr_values
 | ;
 
 datatype: INT 
 | DATA_TYPE 
 | SIZE_MODIFIER grammar 
 | SIGN sign_grammar
 | SCOPE scope_grammar
 | datatype star; 
 
 star: '*' star| '*';
 scope_grammar: INT| DATA_TYPE| SIGN grammar| ;
 sign_grammar: INT| SIZE_MODIFIER grammar| ;
 grammar: INT| ;
 
 function_declaration: fun_datatype fun_param;
 
 fun_datatype: datatype ID '(' ;

 fun_param: param ')' statement {//add to table //reset list};
 
param: datatype all_param_id 
| ;
 
 all_param_id: param_id multiple_param;
 
 multiple_param: ',' param| ;
 
 param_id: ID ext_param;
 
 ext_param: '[' ']'| ;
 
 statement: expression_statement
 | multiple_statements
 | conditional_statement
 | iterartive_statement
 | return_statement
 | break_statement
 | continue_statement
 | switch_statement
 | variable_declaration;
 multiple_statements: '{' block '}' ;
 block: statement block
 | ;
 expression_statement: exp ';'| exp ',' expression_statement
 | ';' ;
 conditional_statement: IF '(' simple_exp ')' statement
 extended_conditional_statement;
 extended_conditional_statement: ELSE statement
 | ;
 iterartive_statement: WHILE '(' simple_exp ')' statement
 | FOR '(' for_initialise simple_exp ';' exp ')'
 | DO statement WHILE '(' simple_exp ')' ';';
 switch_statement: SWITCH '('simple_exp')' '{' case_st DEFAULT ':'
 statement '}';
 case_st: CASE int_char_const ':' statement BREAK ';' case_st
 | ;
int_char_const: INT_CONST
 | CHAR_CONST;
 for_initialise: variable_declaration
 | exp ';'
 | ';' ;
 return_statement: RETURN return_suffix;
 return_suffix: ';'
 | exp ';' ;
 break_statement: BREAK ';' ;
 continue_statement: CONTINUE ';' ;
 exp: identifier expression
 | simple_exp ;
 expression: '=' exp
 | OP_EQUAL exp
 | INC_DEC ;
 simple_exp: unary_relation_exp rel_exp_breakup;
 rel_exp_breakup: LOG unary_relation_exp rel_exp_breakup
 | ;
 unary_relation_exp: NOT unary_relation_exp
 | regular_exp ;
 regular_exp: arithmetic_exp regular_exp_breakup;
 regular_exp_breakup: REL arithmetic_exp
 | ;
 arithmetic_exp: arithmetic_exp operators factor
 | factor ;
 operators: '+'
 | '-'
 | '*'
| '/'
 |'^'
 | '%';
 factor: fun
 | identifier ;
 identifier: ID
 | '&' ID
 | identifier ext_identifier;
 ext_identifier: '[' exp ']'
 | '.' ID;
 | "->" ID; 
 fun: '(' exp ')'
 | fun_call
 | constant;
 fun_call: ID '(' arg ')';
 arg: arg_list
 | ;
 arg_list: exp ext_arg;
 ext_arg: ',' exp ext_arg
 | ;
 constant: INT_CONST
 | STR_CONST
 | FLOAT_CONST
 | CHAR_CONST;
 %%
 extern FILE *yyin;
 extern int yylineno;
 extern char *yytext;
 int main(){
 yyin=fopen("input.c","r");
 yyparse();
 if(flag==0){
 printf("VALID PARSE\n");

// Printing the constant table
token *cur = constant_head;
printf("CONSTANT TABLE\n");
printf("%-20s %-20s\n", "     CONSTANT", "      TYPE");
printf("%-20s %-20s\n", "-------------------", "-------------------");
while(cur != NULL) {
    printf("%-20s %-20s\n", cur->key, cur->value);
    printf("%-20s %-20s\n", "-------------------", "-------------------");
    cur = cur->next;
}

 
 }
 }
 int yyerror(char *s){
 printf("Line No. : %d %s %s\n",yylineno, s, yytext);
 flag=1;
 printf("INVALID PARSE\n");

 }