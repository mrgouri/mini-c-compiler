%{
    void yyerror(char *s);
    int yylex();
    #include "stdio.h"
    #include "stdlib.h"
    #include "ctype.h"
    #include "string.h"
   #include "semantic.h"
    void insert_type();
    void insert_value();
    void insert_dimensions();
    void insert_parameters();
    void remove_scope(int);
    int check_scope(char *);
    int check_function(char *);
    void insert_SymbolTable_nest(char *, int);
    void insert_SymbolTable_paramscount(char *, int);
    int getSTparamscount(char *);
    int getSTdimensioncount(char *);
    int check_duplicate(char *);
    int check_declaration(char *, char *);
    int check_params(char *);
    int duplicate(char *s);
    int check_array(char *);
    void insert_SymbolTable_function(char *);
    void updateDefine(char *);
    char gettype(char *, int);
    extern int flag;
    int insert_flag = 0;
    extern char current_identifier[20];
    extern char current_type[20];
    extern char current_value[20];
    extern char current_function[20];
    extern char previous_operator[20];
    extern int current_nested_val;
    extern int switch_index;
    extern char switch_array[20][20];
    char currfunctype[100];
    char currfunccall[100];
    extern int params_count;
    int call_params_count;
    int current_array_dimensions;
    int actual_dimensions;
    char* getVariableType(char* identifier);
    int checkTypeCompatibility(char* expectedType, char* actualType);
    char* getParameterType(char* funcName, int paramIndex);
    char* getArgumentType(int argIndex);
    char current_call_argument_types[10][20];
    int current_exp_type = -1;

    int switch_index=0;
char switch_array[20][20];
extern FILE *yyin;
extern int yylineno;
extern char *yytext;
void insert_SymbolTable_type(char *,char *);
void insert_SymbolTable_value(char *, char *);
void insert_ConstantTable(char *, char *);
void insert_SymbolTable_arraydim(char *, char *);
void insert_SymbolTable_funcparam(char *, char *);
void printSymbolTable();
void printConstantTable();

struct SymbolTable{
    char symbol_name[100];
    char symbol_type[100];
        char array_dimensions[100];
    char class[100];
        char value[100];
        char parameters[100];
        int line_number;
    int exist;
    int define;
    int nested_val;
    int params_count;
  };

  extern struct SymbolTable ST[1000];

%}

%nonassoc IF
%token INT CHAR FLOAT DOUBLE LONG SHORT SIGNED UNSIGNED STRUCT STRUCT_ASSIGN
%token RETURN MAIN VOID WHILE FOR DO BREAK CONTINUE GOTO ENDIF SWITCH CASE DEFAULT
%token identifier array_identifier integer_constant string_constant float_constant character_constant
%nonassoc ELSE

%right MOD_EQUAL
%right MULTIPLY_EQUAL DIVIDE_EQUAL
%right ADD_EQUAL SUBTRACT_EQUAL
%right '='

%left OR_OR
%left AND_AND
%left '^'
%left EQUAL NOT_EQUAL
%left LESS_EQUAL LESS GREAT_EQUAL GREAT
%left '+' '-'
%left '*' '/' '%'

%right SIZEOF
%right NOT
%left INCREMENT DECREMENT

%start begin_parse

%%

begin_parse
    : declarations
    ;

declarations
    : declaration declarations
    | 
    ;

declaration
    : variable_dec
    | function_dec
    | structure_dec
    | fun_decl
    ;

structure_dec
    : STRUCT identifier { insert_type(); } '{' structure_content '}' struct_name ';'
    ;

structure_content
    : variable_dec structure_content
    | structure_dec structure_content
    | 
    ;

struct_name
    : variables
    | 
    ;

variable_dec
    : structure_initialize ';'
    | datatype variables ';'
    ;

structure_initialize
    : STRUCT struct_init_identifier struct_star variables
    ;

struct_init_identifier
    : identifier { if (gettype(current_identifier, 0) != 's') { printf("%s\n", current_identifier); yyerror("Identifier undeclared or out of scope\n"); }}
    ;

struct_star
    : '*' struct_star
    | 
    ;

variables
    : identifier_name multiple_variables
    ;

multiple_variables
    : ',' variables
    | 
    ;

identifier_name
    : identifier {
        if (check_function(current_identifier)) { yyerror("ERROR: Identifier cannot be same as function name!\n"); exit(8); }
        if (duplicate(current_identifier)) { yyerror("Duplicate value!\n"); exit(0); }
        insert_SymbolTable_nest(current_identifier, current_nested_val);
        insert_type();
    } extended_identifier
    | array_identifier {
        if (duplicate(current_identifier)) { yyerror("Duplicate value!\n"); exit(0); }
        insert_SymbolTable_nest(current_identifier, current_nested_val);
        insert_type();
    } extended_identifier
    ;

extended_identifier
    : array_iden
    | '=' { strcpy(previous_operator, "="); } condition_ternary{printf("^^^ %d\n",$3); if($3 <1) {yyerror("Invalid expression.\n");}}
    ;

array_iden
    : '[' array_dims
    | 
    ;

array_dims
    : integer_constant { insert_dimensions(); } ']' initialization{if($$ < 1) {yyerror("Array must have size greater than 1!\n");}}
    | ']' string_initialization
    | float_constant { insert_dimensions(); } ']' initialization{yyerror("Array size must be an integer!\n");}
    | string_constant { insert_dimensions(); } ']' initialization{yyerror("Array size must be an integer!\n");}
    | expression { insert_dimensions(); } ']' initialization{if($1 == 3) {yyerror("Array size must be an integer!\n");}else if($$ < 1) {yyerror("Array must have size greater than 1!\n");} current_exp_type = -1;}
    ;

initialization
    : string_initialization
    | array_initialization
    | 
    ;

string_initialization
    : '=' { strcpy(previous_operator, "="); } string_constant { insert_value(); }
    ;

array_initialization
    : '=' { strcpy(previous_operator, "="); } multi_dim
    ;

multi_dim
    : '{' arr_elements '}'
    ;

arr_elements
    : array_values
    | '{' array_values '}'
    | multi_dim
    | multi_dim ',' '{' arr_elements '}'
    | '{' array_values '}' ',' arr_elements
    ;

array_values
    : constant multiple_array_values
    ;

multiple_array_values
    : ',' array_values
    | 
    ;

datatype
    : INT | CHAR | FLOAT | DOUBLE
    | LONG long_grammar
    | SHORT short_grammar
    | UNSIGNED unsigned_grammar
    | SIGNED signed_grammar
    | VOID
    | datatype star
    ;

star
    : star '*' { strcat(current_type, "*"); }
    | '*' { strcat(current_type, "*"); }
    ;

unsigned_grammar
    : INT | LONG long_grammar | SHORT short_grammar | 
    ;

signed_grammar
    : INT | LONG long_grammar | SHORT short_grammar | 
    ;

long_grammar
    : INT
    | 
    ;

short_grammar
    : INT
    | 
    ;

function_dec
    : function_datatype function_parameters;


fun_decl : ';';


function_datatype
    : datatype identifier '(' {
        strcpy(currfunctype, current_type);
        check_duplicate(current_identifier);
        insert_SymbolTable_function(current_identifier);
        strcpy(current_function, current_identifier);
        insert_type();
    }
    ;

func_param : func_param ',' datatype | datatype ;


function_parameters
    : parameters ')' { params_count = 0; } body
    ;
body : statements {printf("\n=...DEFINE...=%s\n",current_function); } 
| ';' { printf("\n=...DECLARE...=%s\n",current_function);};
parameters
    : datatype { check_params(current_type); } all_parameter_identifiers { insert_SymbolTable_paramscount(current_function, params_count); }
    | 
    ;

all_parameter_identifiers
    : parameter_identifier multiple_parameters
    ;

multiple_parameters
    : ',' parameters
    | 
    ;

parameter_identifier
    : identifier {
        insert_parameters();
        insert_type();
        insert_SymbolTable_nest(current_identifier, 1);
        params_count++;
    } extended_parameter
    ;

extended_parameter
    : '[' ']'
    | 
    ;

statement
    : expression_statement {$$ = $1;}
    | multiple_statement 
    | conditional_statements
    | iterative_statements
    | return_statement
    | break_statement
    | switch_statement
    | variable_dec
    | function_dec
    ;

switch_statement
    : SWITCH '(' simple_expression ')' { if ($3 != 1) { yyerror("ERROR: Condition must have integer value!\n"); exit(0); }}
      '{' case_statement DEFAULT ':' statement '}'
    ;

case_statement
    : CASE int_char_const {
        if (switch_check(current_value, switch_array, switch_index)) {
            yyerror("ERROR: Duplicate case value");
        } else {
            switch_insert(current_value, switch_array, &switch_index);
        }
    } ':' case_body case_break case_statement
    | 
    ;

case_body
    : statement {$$ = $1;}
    | 
    ;

case_break
    : break_statement
    | 
    ;

int_char_const
    : integer_constant {$$ = 1;}
    | character_constant {$$ = 2;}
    ;

multiple_statement
    : { current_nested_val++; } '{' statements '}' { remove_scope(current_nested_val); current_nested_val--; }
    ;

statements
    : statement statements {$$ = $2>$2? $1 : $2;}
    | 
    ;

expression_statement
    : expression ';'{if($1 == -1) {yyerror("Cannot perform this operation\n."); $$ = -1;} else {$$ = 1;}current_exp_type = -1;}
    | expression {current_exp_type = -1;} ',' expression_statement {$$ = $1>$4? $1 : $4;}
    | ';'
    ;

conditional_statements
    : IF '(' simple_expression ')' {if ($3 != 1) { yyerror("ERROR: Condition must have integer value!\n"); $$ = -1;} else $$ = 1;} statement extended_conditional_statements
    | condition_ternary {$$ = $1;}
    ;

extended_conditional_statements
    : ELSE statement {$$ = $2;}
    | 
    ;

condition_ternary
    : '(' expression {current_exp_type = -1;} ')' '?' condition_ternary ':' condition_ternary {$$ = $2 * $6 * $8 > 0? 1 : -1;}
    | '(' conditional_statements ')' {$$ = $2;}
    | expression { $$ = $1; printf("Hi at ternary! %d\n", $$);current_exp_type = -1;}
    ;

iterative_statements
    : WHILE '(' simple_expression ')' {printf("%d\n",$3); if ($3 < 1) { yyerror("ERROR: Condition must have integer value!\n");  } $$ = 1;} statement
    | FOR '(' for_initialization simple_expression ';' {if($4<1){yyerror("Here, condition must have integer value!\n");}} expression {current_exp_type = -1; $$ = 1;} ')'
    | DO statement WHILE '(' simple_expression ')' { if ($5 < 1) { yyerror("ERROR: Condition must have integer value!\n");  } $$ = 1;} ';'
    ;

for_initialization
    : variable_dec
    | mutable ',' for_initialization
    | expression ';' {current_exp_type = -1;}
    | expression ','{current_exp_type = -1;} for_initialization
    | variable_dec ',' for_initialization
    | ';'
    ;

simple_expression_for
    : simple_expression
    | simple_expression ',' simple_expression_for
    | ';'
    ;

expression_for
    : expression {current_exp_type = -1;}
    | expression ','{current_exp_type = -1;} expression_for
    | 
    ;

return_statement
    : RETURN ';' { if (strcmp(currfunctype, "void")) { yyerror("ERROR: Cannot have void return for non-void function!\n"); }}
    | RETURN expression ';' { if (!strcmp(currfunctype, "void")) {
        yyerror("Non-void return for void function!"); current_exp_type = -1;
    }
    if ((currfunctype[0] == 'i' || currfunctype[0] == 'c') && $2 != 1) {
        yyerror("Expression doesn't match return type of function\n");
    }}
    ;

break_statement
    : BREAK ';'
    ;

expression
    :expression '+' term { printf("At expression 1\n");
        if ($1 == -1 || $3 == -1) {
            yyerror("Cannot perform arithmetic operations on strings");
            $$ = -1;
        } else {
            $$ = $1>$3? $1 : $3;
        }
    } 
    |mutable '=' expression { strcpy(previous_operator, "=");
        if ($1 >= 1 && $3 >= 1) { $$ = $1>$3? $1 : $3; }
        else { $$ = -1; yyerror("Type Mismatch\n"); }
    }
    | mutable ADD_EQUAL expression { strcpy(previous_operator, "+=");
        if ($1 >= 1 && $3 >= 1) { $$ = $1>$3? $1 : $3; }
        else { $$ = -1; yyerror("Type Mismatch\n"); }
    }
    | mutable SUBTRACT_EQUAL expression { strcpy(previous_operator, "-=");
        if ($1 >= 1 && $3 >= 1) { $$ = $1>$3? $1 : $3; }
        else { $$ = -1; yyerror("Type Mismatch\n"); }
    }
    | mutable MULTIPLY_EQUAL expression { strcpy(previous_operator, "*=");
        if ($1 >= 1 && $3 >= 1) { $$ = $1>$3? $1 : $3; }
        else { $$ = -1; yyerror("Type Mismatch\n");  }
    }
    | mutable DIVIDE_EQUAL expression { strcpy(previous_operator, "/=");
        if ($1 >= 1 && $3 >= 1) { $$ = $1>$3? $1 : $3; }
        else { $$ = -1; yyerror("Type Mismatch\n");  }
    }
    | mutable MOD_EQUAL expression { strcpy(previous_operator, "%=");
        if ($1 >= 1 && $3 >= 1) { $$ = $1>$3? $1 : $3; }
        else { $$ = -1; yyerror("Type Mismatch\n"); }
    }
    | mutable INCREMENT { if ($1 >= 1) $$ = $1; else $$ = -1; }
    | mutable DECREMENT { if ($1 >= 1) $$ = $1; else $$ = -1; }
    | simple_expression { if ($1 >= 0) $$ = $1; else $$ = -1; printf("At simple exp %d\n",$$);}
    ;

simple_expression
    : simple_expression OR_OR and_expression { if ($1 >= 1 && $3 >= 1) {printf("one");$$ = $1>$3? $1 : $3;} else {printf("two");$$ = -1; }}
    | and_expression { if ($1 >= 0) {printf("three");$$ = $1;} else {printf("tt");$$ = -1; }}
    ;

and_expression
    : and_expression AND_AND unary_relation_expression { if ($1 >= 1 && $3 >= 1) $$ = $1>$3? $1 : $3; else $$ = -1; }
    | unary_relation_expression { if ($1 >= 0) $$ = $1; else $$ = -1; }
    ;

unary_relation_expression
    : NOT unary_relation_expression { if ($2 >= 1) $$ = $2; else $$ = -1; }
    | regular_expression { if ($1 >= 0) $$ = $1; else $$ = -1; }
    ;

regular_expression
    : regular_expression relational_operators sum_expression { if ($1 >= 1 && $3 >= 1) $$ = $1>$3? $1 : $3; else $$ = -1; }
    | sum_expression {  $$ = $1;  }
    ;

relational_operators
    : GREAT_EQUAL { strcpy(previous_operator, ">="); }
    | LESS_EQUAL { strcpy(previous_operator, "<="); }
    | GREAT { strcpy(previous_operator, ">"); }
    | LESS { strcpy(previous_operator, "<"); }
    | EQUAL { strcpy(previous_operator, "=="); }
    | NOT_EQUAL { strcpy(previous_operator, "!="); }
    ;

sum_expression
    : sum_expression sum_operators term { if ($1 >= 1 && $3 >= 1) $$ = $1>$3? $1 : $3; else $$ = -1; }
    | term { printf(" Ive come to term! "); if ($1 >= 0) $$ = $1; else $$ = -1; }
    ;

sum_operators
    : '+'
    | '-'
    | '='{yyerror("Line no. Error: Invalid lhs value\n"); exit(0);}
    ;

term
    : term MULOP factor {  if ($1 >= 1 && $3 >= 1) $$ = $1>$3? $1 : $3; else $$ = -1; }
    | factor { printf("%d\n",$1);if ($1 >= 0) $$ = $1; else $$ = -1; }
    ;

MULOP
    : '*' | '/' | '%'
    ;

factor
    : immutable { printf("%d\n",$1);if ($1 >= 1) $$ = $1; else $$ = -1; }
    | mutable { if ($1 >= 0) $$ = $1; else $$ = -1; }
    ;

mutable
    : identifier {
        if (!check_scope(current_identifier)) { 
            yyerror("Identifier undeclared or out of scope"); 

        }
        if (gettype(current_identifier, 0) == 's') {
            $$ = 0;  // Indicate it's a string
            printf(" IM in String mutable");
        } else if (gettype(current_identifier, 0) == 'i') {
            $$ = 1;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<1? 1: current_exp_type ;
        }
        else if (gettype(current_identifier, 1) == 'c') {
            $$ = 2;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<2? 2: current_exp_type ;
        }
        else if (gettype(current_identifier, 1) == 'f') {
            $$ = 3;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }
         else {
            $$ = -1;
        }
    }
    | '&' identifier {
        if (!check_scope(current_identifier)) { printf("%s\n", current_identifier); yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) { printf("%s\n", current_identifier); yyerror("Array Identifier has No Subscript\n");  }
        if (gettype(current_identifier, 0) == 's') {
            $$ = 0;  // Indicate it's a string
            printf(" IM in String mutable");
        } else if (gettype(current_identifier, 0) == 'i') {
            $$ = 1;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<1? 1: current_exp_type ;
        }
        else if (gettype(current_identifier, 1) == 'c') {
            $$ = 2;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<2? 2: current_exp_type ;;
        }
        else if (gettype(current_identifier, 1) == 'f') {
            $$ = 3;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }
         else {
            $$ = -1;
        }
    }
    | identifier INCREMENT {
        if (!check_scope(current_identifier)) { printf("%s\n", current_identifier); yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) { printf("%s\n", current_identifier); yyerror("Array Identifier has No Subscript\n");  }
        if (gettype(current_identifier, 0) == 's') {
            $$ = 0;  // Indicate it's a string
            printf(" IM in String mutable");
        } else if (gettype(current_identifier, 0) == 'i') {
            $$ = 1;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<1? 1: current_exp_type ;
        }
        else if (gettype(current_identifier, 1) == 'c') {
            $$ = 2;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<2? 2: current_exp_type ;;
        }
        else if (gettype(current_identifier, 1) == 'f') {
            $$ = 3;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }
         else {
            $$ = -1;
        }
    }
    | identifier DECREMENT {
        if (!check_scope(current_identifier)) { printf("%s\n", current_identifier); yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) { printf("%s\n", current_identifier); yyerror("Array Identifier has No Subscript\n");  }
        if (gettype(current_identifier, 0) == 's') {
            $$ = 0;  // Indicate it's a string
            printf(" IM in String mutable");
        } else if (gettype(current_identifier, 0) == 'i') {
            $$ = 1;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<1? 1: current_exp_type ;
        }
        else if (gettype(current_identifier, 1) == 'c') {
            $$ = 2;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<2? 2: current_exp_type ;;
        }
        else if (gettype(current_identifier, 1) == 'f') {
            $$ = 3;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }
         else {
            $$ = -1;
        }
    }
    | INCREMENT identifier {
        if (!check_scope(current_identifier)) { printf("%s\n", current_identifier); yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) { printf("%s\n", current_identifier); yyerror("Array Identifier has No Subscript\n"); }
        if (gettype(current_identifier, 0) == 's') {
            $$ = 0;  // Indicate it's a string
            printf(" IM in String mutable");
        } else if (gettype(current_identifier, 0) == 'i') {
            $$ = 1;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<1? 1: current_exp_type ;
        }
        else if (gettype(current_identifier, 1) == 'c') {
            $$ = 2;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<2? 2: current_exp_type ;;
        }
        else if (gettype(current_identifier, 1) == 'f') {
            $$ = 3;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }
         else {
            $$ = -1;
        }
    }
    | DECREMENT identifier {
        if (!check_scope(current_identifier)) { printf("%s\n", current_identifier); yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) { printf("%s\n", current_identifier); yyerror("Array Identifier has No Subscript\n");  }
        if (gettype(current_identifier, 0) == 's') {
            $$ = 0;  // Indicate it's a string
            printf(" IM in String mutable");
        } else if (gettype(current_identifier, 0) == 'i') {
            $$ = 1;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<1? 1: current_exp_type ;
        }
        else if (gettype(current_identifier, 1) == 'c') {
            $$ = 2;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<2? 2: current_exp_type ;;
        }
        else if (gettype(current_identifier, 1) == 'f') {
            $$ = 3;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }
         else {
            $$ = -1;
        }
    }
    | '+' identifier {
        if (!check_scope(current_identifier)) { printf("%s\n", current_identifier); yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) { printf("%s\n", current_identifier); yyerror("Array Identifier has No Subscript\n"); }
        if (gettype(current_identifier, 0) == 's') {
            $$ = 0;  // Indicate it's a string
            printf(" IM in String mutable");
        } else if (gettype(current_identifier, 0) == 'i') {
            $$ = 1;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<1? 1: current_exp_type ;
        }
        else if (gettype(current_identifier, 1) == 'c') {
            $$ = 2;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<2? 2: current_exp_type ;;
        }
        else if (gettype(current_identifier, 1) == 'f') {
            $$ = 3;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }
         else {
            $$ = -1;
        }
    }
    | '-' identifier {
        if (!check_scope(current_identifier)) { printf("%s\n", current_identifier); yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) { printf("%s\n", current_identifier); yyerror("Array Identifier has No Subscript\n"); }
        if (gettype(current_identifier, 0) == 's') {
            $$ = 0;  // Indicate it's a string
            printf(" IM in String mutable");
        } else if (gettype(current_identifier, 0) == 'i') {
            $$ = 1;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<1? 1: current_exp_type ;
        }
        else if (gettype(current_identifier, 1) == 'c') {
            $$ = 2;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<2? 2: current_exp_type ;;
        }
        else if (gettype(current_identifier, 1) == 'f') {
            $$ = 3;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }
         else {
            $$ = -1;
        }
    }
    | array_identifier { 
        actual_dimensions = getSTdimensioncount(current_identifier);
        current_array_dimensions = 0;
        if (!check_scope(current_identifier)) { printf("%s\n", current_identifier); yyerror("Identifier undeclared or out of scope\n"); }
    } '[' { current_array_dimensions++; } expression ']' extended_array_dimension {
        if (gettype(current_identifier, 0) == 's') {
            $$ = 0;  // Indicate it's a string
            printf(" IM in String mutable");
        } else if (gettype(current_identifier, 0) == 'i') {
            $$ = 1;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<1? 1: current_exp_type ;
        }
        else if (gettype(current_identifier, 1) == 'c') {
            $$ = 2;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<2? 2: current_exp_type ;
        }
        else if (gettype(current_identifier, 1) == 'f') {
            $$ = 3;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }
         else {
            $$ = -1;
        }
    }
    | struct_identifier STRUCT_ASSIGN mutable {
        if (!check_scope(current_identifier)) { printf("%s\n", current_identifier); yyerror("Identifier undeclared or out of scope\n"); }
        if (!check_array(current_identifier)) { printf("%s\n", current_identifier); yyerror("Array Identifier has No Subscript\n");  }
        if (gettype(current_identifier, 0) == 's') {
            $$ = 0;  // Indicate it's a string
            printf(" IM in String mutable");
        } else if (gettype(current_identifier, 0) == 'i') {
            $$ = 1;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<1? 1: current_exp_type ;
        }
        else if (gettype(current_identifier, 1) == 'c') {
            $$ = 2;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<2? 2: current_exp_type ;;
        }
        else if (gettype(current_identifier, 1) == 'f') {
            $$ = 3;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }
         else {
            $$ = -1;
        }
    }
    ;

struct_identifier
    : identifier {
        if (!check_scope(current_identifier)) { printf("%s\n", current_identifier); yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) { printf("%s\n", current_identifier); yyerror("Array Identifier has No Subscript\n"); }
        if (gettype(current_identifier, 0) == 's') $$ = 0;
        else { yyerror("Identifier not of struct type\n");  $$ = -1; }
    }
    ;

extended_array_dimension
    : '[' { current_array_dimensions++; } expression ']' extended_array_dimension
    | { if (current_array_dimensions != actual_dimensions) { printf("%s\n", current_identifier); yyerror("Dimensions mismatch of the array\n"); }}
    ;

immutable
    : '(' expression ')' { if ($2 >= 1) $$ = $2; else $$ = -1; }
    | call {$$ = $1;}
    | constant_noString { if ($1 >= 0) $$ = $1; else $$ = -1; }
    ;
constant_noString : integer_constant { insert_type(); $$ = 1; }
    | string_constant { insert_type(); $$ = 0;}
    | float_constant { insert_type(); $$ = 3; }
    | character_constant { insert_type(); $$ = 2; }
    ;

call
    : identifier '(' {
        strcpy(previous_operator, "(");
        if (!check_declaration(current_identifier, "Function")) {
            yyerror("Function not declared");
        }
        char tp = gettype(current_identifier,0);
        if (tp == 's') {
            $$ = 0;  // Indicate it's a string
            printf(" IM in String mutable");
        } else if (tp == 'i') {
            $$ = 1;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<1? 1: current_exp_type ;
        }
        else if ( tp == 'c') {
            $$ = 2;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<2? 2: current_exp_type ;;
        }
        else if (tp == 'f') {
            $$ = 3;  // Indicate it's a numeric type
            current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }
         else {
            $$ = -1;
        }
        insert_SymbolTable_function(current_identifier);
        strcpy(currfunccall, current_identifier);
        call_params_count = 0;
    } arguments ')' {
        //printSymbolTable();
        printf("$$$ in arguments %s\n",currfunccall);
        if (strcmp(currfunccall, "printf")) {
            if (getSTparamscount(currfunccall) != call_params_count) {
                yyerror("Number of parameters not same as number of arguments during function call!");

            }
            for (int i = 0; i < call_params_count; i++) {
                char* expectedType = getParameterType(currfunccall, i);
                printf("Expexted type = %s\n",expectedType);
                char* actualType = getArgumentType(i);
                if (!checkTypeCompatibility(expectedType, actualType)) {
                    char error_message[100];
                    sprintf(error_message, "Type mismatch in function call: expected %s but got %s for argument %d", 
                            expectedType, actualType, i+1);
                    yyerror(error_message);

                }
            }
        }
        call_params_count = 0;
    }
    ;

arguments
    : arguments_list
    | 
    ;

arguments_list
    : expression { 
        strcpy(current_call_argument_types[call_params_count], getVariableType(current_identifier));
        call_params_count++; 
    } A
    ;

A
    : ',' expression { 
        strcpy(current_call_argument_types[call_params_count], getVariableType(current_identifier));
        call_params_count++; 
    } A
    | 
    ;

constant
    : integer_constant { insert_type(); $$ = 1; }
    | string_constant { insert_type(); $$ = 0; }
    | float_constant { insert_type(); $$ = 3; }
    | character_constant { insert_type(); $$ = 2; }
    ;

%%


void yyerror(char *s) {
    printf("Line No. : %d %s %s\n", yylineno, s, yytext);
    flag = 1;
    printf("\nUNSUCCESSFUL: INVALID PARSE\n");
}

void insert_type() {
    insert_SymbolTable_type(current_identifier, current_type);
}

void insert_value() {
    if (strcmp(previous_operator, "=") == 0) {
        insert_SymbolTable_value(current_identifier, current_value);
    }
}

void insert_dimensions() {
    insert_SymbolTable_arraydim(current_identifier, current_value);
}

void insert_parameters() {
    insert_SymbolTable_funcparam(current_function, current_type);
}

//int yywrap() {
//    return 1;
//}*/
char* getVariableType(char* id) {

    return current_type;
}

char* getParameterType(char* funcName, int paramIndex) {
    char* p = NULL;
    int pc = 0;
    for(int i = 0 ; i < 1000 ; i++)
    {
      if(strcmp(ST[i].symbol_name,funcName)==0 )
      {
        p = ST[i].parameters;
        pc = ST[i].params_count;
        break;
      }
    }
    if(p == NULL)
    return "void";

    if(paramIndex >= pc)
    return "error";

    char res[100] = "";
    int count = -1;
    for(int i = 0;i<100;i++){
        printf("im here %d %c %d %d \n",i,p[i],count,paramIndex);
        if(p[i] == ' '){
            count++;
            continue;
        }

        printf("hiii");

        if(count == paramIndex){
            int len = strlen(res);  // Find the current length of the string.
            res[len] = p[i];          // Add the new character at the end of the string.
            res[len + 1] = '\0';
            printf("here: %s\n",res);
        }
        else if(count>paramIndex){
            break;
        }

        printf("hiii");
    }

    return strdup(res);
}

char* getArgumentType(int argIndex) {

    return current_call_argument_types[argIndex];
}

int checkTypeCompatibility(char* expectedType, char* actualType) {
    if (strcmp(expectedType, actualType) == 0) {
        return 1;
    }
    if (strcmp(expectedType, "float") == 0 && strcmp(actualType, "int") == 0) {
        return 1;
    }
    return 0; 
}

int main() {
    yyin = fopen("e28.c", "r");
    yyparse();

    if (flag == 0) {
        printf("VALID PARSE\n");
        printf("%30s SYMBOL TABLE \n", " ");
        printf("%30s %s\n", " ", "------------");
        printSymbolTable();

        printf("\n\n%30s CONSTANT TABLE \n", " ");
        printf("%30s %s\n", " ", "--------------");
        printConstantTable();
    }
}
/*void yyerror(char *s) {
    printf("Line No.: %d %s %s\n", yylineno, s, yytext);
    flag = 1;
    printf("\nUNSUCCESSFUL: INVALID PARSE\n");
}

void insert_type() {
    insert_SymbolTable_type(current_identifier, current_type);
}

void insert_value() {
    if (strcmp(previous_operator, "=") == 0) {
        insert_SymbolTable_value(current_identifier, current_value);
    }
}

void insert_dimensions() {
    insert_SymbolTable_arraydim(current_identifier, current_value);
}

void insert_parameters() {
    insert_SymbolTable_funcparam(current_function, current_type);
}*/

int yywrap() {
    return 1;
}