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
    void top_();
    void insert_dimensions();
    void insert_parameters();
    void remove_scope(int);
    int check_scope(char *);
    int check_function(char *);
    void insert_SymbolTable_nest(char *, int);
    void insert_SymbolTable_paramscount(char *, int);
    int isNotPointer(char *);
    int getSTparamscount(char *);
    int getSTdimensioncount(char *);
    int check_duplicate(char *);
    int check_declaration(char *, char *);
    int check_params(char *);
    int func_exist(char*);
     void updateDefine(char *);
    int duplicate(char *s);
    int check_array(char *);
    void insert_SymbolTable_function(char *);
    char gettype(char *, int);
    void push(char *s);
	void codegen();
	void codeassign();
	char* itoa(int num, char* str, int base);
	void reverse(char str[], int length);
	void swap(char*,char*);
	void label1();
	void label2();
	void label3();
	void label4();
	void label5();
	void label6();
	void genunary();
	void codegencon();
    void appendTop(char*);
	void start_function();
	void end_function();
	void arggen();
	void callgen();
    extern int flag;
    int insert_flag = 0;
    int call_params_count=0;
	int array_flag = 0;
	int array_tac_flag = 0;
	int top = 0,count=0,ltop=0,lno=0;
	char temp[3] = "t";
    extern char current_identifier[20];
    extern char current_whatever[20];
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
    int printCount=0;

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
int newCheckCompatibility(int a, int b);
int giveIndex(char* name);
int checkConstantTable(char* s);
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
    int curr_nest_val;
    int params_count;
  };

    struct ConstantTable{
    char constant_name[100];
    char constant_type[100];
    int exist;
  };
  
  extern struct ConstantTable CT[1000];

  extern struct SymbolTable ST[1000];

  int newGetType(char* s);
  int current_exp_type2 = -1;
  char* identifier2;
  char* struck_var;
  char* curr_indi;
  //char* onlyVariable;

%}

%nonassoc IF
%token INT CHAR FLOAT DOUBLE LONG SHORT SIGNED UNSIGNED STRUCT STRUCT_ASSIGN
%token RETURN MAIN DOT

%token VOID NULL_CONST
%token WHILE FOR DO
%token BREAK CONTINUE GOTO
%token ENDIF
%token SWITCH CASE DEFAULT
%token identifier array_identifier 
%token integer_constant string_constant float_constant character_constant
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
    : identifier { if (gettype(current_identifier, 0) != 's') {   yyerror("Identifier undeclared or out of scope\n"); }}
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
        push(current_identifier);
        identifier2 = strdup(current_identifier);
        if (duplicate(current_identifier)) { yyerror("Duplicate value!\n");  }
        insert_SymbolTable_nest(current_identifier, current_nested_val);
        insert_type();
    } extended_identifier { if (($3<= 5) && (newCheckCompatibility(newGetType(identifier2), $3) != 1)) {yyerror("ERROR: Type Mismatch\n"); exit(0);}}
    | array_identifier {
        push(current_identifier);
        if (duplicate(current_identifier)) { yyerror("Duplicate value!\n");  }
        insert_SymbolTable_nest(current_identifier, current_nested_val);
        insert_type();
    } extended_identifier
    ;

extended_identifier
    : array_iden {$$ = 100;}
    | '=' NULL_CONST {if(isNotPointer(current_identifier) )yyerror("NULL ERROR!!!!"); $$ = 6;}
    | '=' {strcpy(previous_operator, "="); push("=");} condition_ternary{ if($3 <1) {yyerror("Invalid expression.\n");} $$ = $3; codeassign();}
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
    | expression { insert_dimensions(); } ']' initialization{if($1 != 1 && $1 != 2) {yyerror("Array size must be an integer!\n");}else if($$ < 1) {yyerror("Array must have size greater than 1!\n");} current_exp_type = -1;}
    ;

initialization
    : string_initialization
    | array_initialization
    | 
    ;

string_initialization
    : '=' { strcpy(previous_operator, "="); } string_constant { codegencon(); insert_value(); }
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
    : function_datatype function_parameters
    ;

fun_decl : ';';


function_datatype
    : datatype identifier '(' {
        strcpy(currfunctype, current_type);
        check_duplicate(current_identifier);
        if(func_exist(current_function)==1) yyerror(" ERROR:Function already defined\n");
        insert_SymbolTable_function(current_identifier);
        strcpy(current_function, current_identifier);
        insert_type();
    }
    ;

func_param : func_param ',' datatype | datatype ;


function_parameters
    : parameters  ')' { params_count = 0; start_function();} body
    ;
body : { updateDefine(current_function); }multiple_statement { end_function();} 
| ';' ;
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
    : SWITCH '(' expression ')' {if ($3 != 1) { yyerror("ERROR: Condition must have integer value!\n"); }} '{' case_statement'}'
    ;

case_statement
    : CASE int_char_const {
        if (switch_check(current_value, switch_array, switch_index)) {
            yyerror("ERROR: Duplicate case value");
        } else {
            switch_insert(current_value, switch_array, &switch_index);
        }
    } ':' case_body case_break case_statement
    |  DEFAULT ':' case_body case_break
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
    : integer_constant {$$ = 1; codegencon();}
    | character_constant {$$ = 2;codegencon();}
    ;

multiple_statement
    : { current_nested_val++; } '{' statements '}' { remove_scope(current_nested_val); current_nested_val--; }
    ;

statements
    : statement  statements {$$ = $2>$2? $1 : $2; }
    | 
    ;

expression_statement
    : expression ';'{if($1 == -1) {yyerror("Cannot perform this operation\n."); $$ = -1;} else {$$ = 1;}current_exp_type = -1;}
    | expression {current_exp_type = -1;} ',' expression_statement {$$ = $1>$4? $1 : $4;}
    | ';'
    ;

conditional_statements
    : IF '(' expression ')' {label1(); if ($3 != 1) { yyerror("ERROR: Condition must have integer value!\n"); $$ = -1;} else $$ = 1;  } statement {label2();} extended_conditional_statements
    | condition_ternary {$$ = $1;}
    ;

extended_conditional_statements
    : ELSE statement {label3(); $$ = $2;}
    | {label3();}
    ;

condition_ternary
    : '(' expression {current_exp_type = -1;} ')' '?' condition_ternary ':' condition_ternary {if($2>0 && $2<4 && $6 > 0 && $6<4 && $8>0 && $8<4) $$ = 1; else $$ = -1;}
    | '(' conditional_statements ')' {$$ = $2;}
    | expression { $$ = $1; current_exp_type = -1;}
    ;

iterative_statements
    : WHILE '(' {label4();} expression ')' {label1();  if ($4 < 1 || $4 > 3) { yyerror("ERROR: Condition must have integer value!\n");  } $$ = 1;} statement {label5();}
    | FOR '(' for_initialization {label4();} expression ';' { if($5<1 || $5 > 3){yyerror("Here, condition must have integer value!\n");} label1();} expression {current_exp_type = -1; $$ = 1;} ')' statement {label5();}
    |{label4();} DO statement WHILE '(' expression ')' {label1(); label5(); if ($6 < 1 || $6>3) { yyerror("ERROR: Condition must have integer value!\n");  } $$ = 1;} ';'
    ;

for_initialization
    : variable_dec
    | mutable ',' for_initialization
    | expression ';' {label4(); current_exp_type = -1;}
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

    //printSymbolTable();
     if (((strcmp(currfunctype,"int") == 0|| strcmp(currfunctype,"char") == 0) && ($2 != 1) && ($2 != 2))) {
        yyerror("Expression doesn't match return type of function\n");
    }
    else if (strcmp(currfunctype,"char*") == 0 && ($2 != 0)) {
        yyerror("Expression doesn't match return type of function\n");
    }
    else if (strcmp(currfunctype,"int*") == 0 && ($2 != 4)) {
        yyerror("Expression doesn't match return type of function\n");
    }
    else if (strcmp(currfunctype,"float*") == 0 && ($2 != 5)) {
        yyerror("Expression doesn't match return type of function\n");
    }

    }
    ;

break_statement
    : BREAK ';'
    ;

expression
    :
    {}NULL_CONST {if(isNotPointer(current_identifier) )yyerror("NULL ERROR!!!!"); else $$=6; push("NULL"); }
   | expression '+' term { 
        if (!($1 >= 1 && $1 <4 && $3 >= 1 && $3 <4)) {
            yyerror("Cannot perform arithmetic operations on strings/pointers");
            $$ = -1;
        } else {
            $$ = $1>$3? $1 : $3;
        }
    } 
    |mutable '=' { push("=");} expression { strcpy(previous_operator, "=");
        if (($1 >= 1 && $1 <4 && $4 >= 1 && $4 <4) || ($1 == $4) || $4 == 6) { $$ = $1>$4? $1 : $4; }
        else { $$ = -1; yyerror("Type Mismatch\n"); }
        codeassign();
    }
    | mutable ADD_EQUAL {push(current_identifier);push("+=");}  expression { strcpy(previous_operator, "+=");
        if ($1 >= 1 && $1 <4 && $4 >= 1 && $4 <4) { $$ = $1>$4? $1 : $4; }
        else { $$ = -1; yyerror("Type Mismatch\n"); }
        codeassign();
    }
    | mutable SUBTRACT_EQUAL {push(current_identifier); push("-=");}  expression { strcpy(previous_operator, "-=");
        if ($1 >= 1 && $1 <4 && $4 >= 1 && $4 <4) { $$ = $1>$4? $1 : $4; }
        else { $$ = -1; yyerror("Type Mismatch\n"); }
        codeassign();
    }
    | mutable MULTIPLY_EQUAL {push(current_identifier); push("*=");} expression { strcpy(previous_operator, "*=");
        if ($1 >= 1 && $1 <4 && $4 >= 1 && $4 <4) { $$ = $1>$4? $1 : $4; }
        else { $$ = -1; yyerror("Type Mismatch\n");  }
        codeassign();

    }
    | mutable DIVIDE_EQUAL {push(current_identifier); push("/=");}  expression { strcpy(previous_operator, "/=");
        if ($1 >= 1 && $1 <4 && $4 >= 1 && $4 <4) { $$ = $1>$4? $1 : $4; }
        else { $$ = -1; yyerror("Type Mismatch\n");  }
        codeassign();
    }
    | mutable MOD_EQUAL {push(current_identifier); push("%=");} expression { strcpy(previous_operator, "%=");
        if ($1 >= 1 && $1 <4 && $4 >= 1 && $4 <4) { $$ = $1>$4? $1 : $4; }
        else { $$ = -1; yyerror("Type Mismatch\n"); }
        codeassign();
    }
    | mutable INCREMENT {push(current_identifier); push("++"); if ($1 >= 1) $$ = $1; else $$ = -1; genunary();}
    | mutable DECREMENT {push(current_identifier); push("--"); if ($1 >= 1) $$ = $1; else $$ = -1; genunary();}
    | simple_expression { if ($1 >= 0) $$ = $1; else $$ = -1;}
    ;

simple_expression
    : simple_expression OR_OR and_expression { if ($1 >= 1 && $1 <4 && $3 >= 1 && $3 <4) {$$ = $1>$3? $1 : $3;} else {$$ = -1; }codegen();}
    | and_expression { if ($1 >= 0) {$$ = $1;} else {$$ = -1; }}
    ;

and_expression
    : and_expression AND_AND unary_relation_expression { if ($1 >= 0 &&  $3 >= 0) $$ = $1>$3? $1 : $3; else $$ = -1; codegen();}
    | unary_relation_expression { if ($1 >= 0) $$ = $1; else $$ = -1; }
    ;

unary_relation_expression
    : NOT unary_relation_expression { if ($2 >= 0) $$ = $2; else $$ = -1; codegen();}
    | regular_expression { if ($1 >= 0) $$ = $1; else $$ = -1; }
    ;

regular_expression
    : regular_expression relational_operators sum_expression { if ($1 >= 0  && $3 >=0) $$ = 1; else $$ = -1; codegen();}
    | sum_expression { $$ = $1;}
    ;

relational_operators
			: GREAT_EQUAL{strcpy(previous_operator,">="); push(">=");}
			| LESS_EQUAL{strcpy(previous_operator,"<="); push("<=");}
			| GREAT{strcpy(previous_operator,">"); push(">");}
			| LESS{strcpy(previous_operator,"<"); push("<");}
			| EQUAL{strcpy(previous_operator,"=="); push("==");}
			| NOT_EQUAL{strcpy(previous_operator,"!="); push("!=");} ;

sum_expression
    : sum_expression sum_operators term { if ($1 >= 1 && $3 >= 1) $$ = $1>$3? $1 : $3; else $$ = -1; codegen();}
    | term { if ($1 >= 0) $$ = $1; else $$ = -1; }
    ;

sum_operators
			: '+' {push("+");}
			| '-' {push("-");} 
    | '='{yyerror("Line no. Error: Invalid lhs value\n"); exit(0);}
    ;

term
    : term MULOP factor {  if ($1 >= 1 && $1 <4 && $3 >= 1 && $3 <4) $$ = $1>$3? $1 : $3; else $$ = -1; codegen();}
    | factor { if ($1 >= 0) $$ = $1; else $$ = -1; }
    ;

MULOP
    : '*' {push("*");}
			| '/' {push("/");}
			| '%' {push("%");} ;
    ;

factor
    : immutable { if ($1 >= 0) $$ = $1; else $$ = -1; }
    | mutable { if ($1 >= 0) $$ = $1; else $$ = -1; }
    ;

mutable
    : identifier { push(current_identifier);
        if (!check_scope(current_identifier)) { 
            yyerror("Identifier undeclared or out of scope"); 

        }

         int typ = newGetType(current_identifier);


        $$ = typ;
        current_exp_type = current_exp_type<$$? $$: current_exp_type ;
        
    } stuck;
    | '&' identifier {
        if (!check_scope(current_identifier)) {   yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) {   yyerror("Array Identifier has No Subscript\n");  }
         int typ = newGetType(current_identifier);
        

        if(typ == 1)
        $$ = 4;
        else if(typ == 3)
        $$ = 5;
        current_exp_type = current_exp_type<$$? $$: current_exp_type ;
        char str2[100];
        snprintf(str2, sizeof(str2), "&%s", current_identifier);
        strcpy(current_value, str2);
        codegencon();
    }
    | identifier INCREMENT {
        if (!check_scope(current_identifier)) {   yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) {   yyerror("Array Identifier has No Subscript\n");  }
         int typ = newGetType(current_identifier);

        $$ = typ;
        current_exp_type = current_exp_type<$$? $$: current_exp_type ;
        push(current_identifier); 
        push("++");
        genunary();
    }
    | identifier DECREMENT {
        if (!check_scope(current_identifier)) {   yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) {  yyerror("Array Identifier has No Subscript\n");  }
         int typ = newGetType(current_identifier);

        $$ = typ;
        current_exp_type = current_exp_type<$$? $$: current_exp_type ;
        push(current_identifier); 
        push("--");
        genunary();
    }
    | INCREMENT identifier {
        if (!check_scope(current_identifier)) {  yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) {  yyerror("Array Identifier has No Subscript\n"); }
        int typ = newGetType(current_identifier);

        $$ = typ;
        current_exp_type = current_exp_type<$$? $$: current_exp_type ;
        push("++");
        push(current_identifier);
        genunary();
    }
    | DECREMENT identifier {
        if (!check_scope(current_identifier)) {  yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) {  yyerror("Array Identifier has No Subscript\n");  }
         int typ = newGetType(current_identifier);

        $$ = typ;
        current_exp_type = current_exp_type<$$? $$: current_exp_type ;
        push("--");
        push(current_identifier);
        genunary();
    }
    | '+' identifier {
        if (!check_scope(current_identifier)) {  yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) {  yyerror("Array Identifier has No Subscript\n"); }
         int typ = newGetType(current_identifier);

        $$ = typ;
        current_exp_type = current_exp_type<$$? $$: current_exp_type ;
    }
    | '-' identifier {
        if (!check_scope(current_identifier)) {  yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) {  yyerror("Array Identifier has No Subscript\n"); }
         int typ = newGetType(current_identifier);

        $$ = typ;
        current_exp_type = current_exp_type<$$? $$: current_exp_type ;
    }
    | array_identifier { push(current_identifier);
        array_flag = 1;
        actual_dimensions = getSTdimensioncount(current_identifier);
        current_array_dimensions = 0;
        if (!check_scope(current_identifier)) {  yyerror("Identifier undeclared or out of scope\n"); }
    } '[' { current_array_dimensions++; } expression ']' extended_array_dimension {
         int typ = newGetType(current_identifier);

        $$ = typ;
        current_exp_type = current_exp_type<$$? $$: current_exp_type ;
    }
    | struct_identifier STRUCT_ASSIGN mutable {
        if (!check_scope(current_identifier)) {  yyerror("Identifier undeclared or out of scope\n"); }
        if (!check_array(current_identifier)) {  yyerror("Array Identifier has No Subscript\n");  }
         int typ = newGetType(current_identifier);

        $$ = typ;
        current_exp_type = current_exp_type<$$? $$: current_exp_type ;
    }
    ;
    stuck: | DOT{ appendTop("."); } identifier { struck_var = strdup(current_identifier); appendTop(current_identifier); push("=");}'='{top_();}expression{if(newCheckCompatibility(newGetType(struck_var), $7) != 1){ char* error_message;sprintf(error_message, "Type mismatch in function call: expected %s but got %s\n", newGetType(struck_var), $7); yyerror(error_message);}top_();codeassign();};

struct_identifier
    : identifier {
        if (!check_scope(current_identifier)) {  yyerror("Identifier undeclared or out of scope\n");  }
        if (!check_array(current_identifier)) {  yyerror("Array Identifier has No Subscript\n"); }
        if (gettype(current_identifier, 0) == 's') $$ = 0;
        else { yyerror("Identifier not of struct type\n");  $$ = -1; }
    }
    ;

extended_array_dimension
    : '[' { current_array_dimensions++; } expression ']' extended_array_dimension
    | { if (current_array_dimensions > actual_dimensions) { yyerror("Dimensions mismatch of the array\n"); }}
    ;

immutable
    : '(' expression ')' { if ($2 >= 1) $$ = $2; else $$ = -1; }
    | call {$$ = $1;}
    | constant_noString { if ($1 >= 0) $$ = $1; else $$ = -1; }
    ;
constant_noString : integer_constant {  insert_type(); $$ = 1; codegencon();}
    | string_constant { codegencon(); insert_type(); $$ = 0;}
    | float_constant {codegencon(); insert_type(); $$ = 3; }
    | character_constant { insert_type(); codegencon(); $$ = 2; }
    ;

call 
    : identifier '(' {
        strcpy(previous_operator, "(");
        if (!check_declaration(current_identifier, "Function")) {
            yyerror("Function not defined");
        }
        char tp = gettype(current_identifier,0);
        int typ = newGetType(current_identifier);
        if (strcmp(current_identifier, "printf") == 0)
        typ = 1;

        $$ = typ;
        current_exp_type = current_exp_type<$$? $$: current_exp_type ;

        //insert_SymbolTable_function(current_identifier);
        strcpy(currfunccall, current_identifier);
        call_params_count = 0;
        current_exp_type2 = $$;
    } arguments ')' {
        if (strcmp(currfunccall, "printf")) {
            if (getSTparamscount(currfunccall) != call_params_count) {
                yyerror("Number of parameters not same as number of arguments during function call!");

            }
            for (int i = 0; i < call_params_count; i++) {
                char* expectedType = getParameterType(currfunccall, i);
                char* actualType = getArgumentType(i);



                if (!checkTypeCompatibility(expectedType, actualType)) {
                    char error_message[100];
                    sprintf(error_message, "Type mismatch in function call: expected %s but got %s for argument %d", 
                            expectedType, actualType, i+1);
                    yyerror(error_message);

                }
            }
        }else printCount=call_params_count;
        call_params_count = 0;
        $$ = current_exp_type2;
    callgen();
    }
    ;

arguments
    : arguments_list
    | 
    ;

arguments_list
    : expression { 
        arggen();
        strcpy(current_call_argument_types[call_params_count], getVariableType(current_whatever));
        call_params_count++; 
    } A
    ;

A
    : ',' expression {
        arggen();
        strcpy(current_call_argument_types[call_params_count], getVariableType(current_whatever));
        call_params_count++; 
    } A
    | 
    ;

constant
    : integer_constant { insert_type(); codegencon(); $$ = 1; }
    | string_constant { insert_type(); codegencon(); $$ = 0; }
    | float_constant { insert_type(); codegencon(); $$ = 3; }
    | character_constant { insert_type(); codegencon(); $$ = 2; }
    ;

%%

extern FILE *yyin;
extern int yylineno;
extern char *yytext;
void insert_SymbolTable_type(char *,char *);
void insert_SymbolTable_value(char *, char *);
void insert_ConstantTable(char *, char *);
void insert_SymbolTable_arraydim(char *, char *);
void insert_SymbolTable_funcparam(char *, char *);

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

     for(int i = 0 ; i < 1001 ; i++ )
      {
        if(strcmp(ST[i].symbol_name,id)==0)
        {
          return (ST[i].symbol_type);
          break;
        }
      }
    
        int t = newGetType(id);
        if(t == 0)
        return "char*";
        else if(t == 1)
        return "int";
        else if(t == 2)
        return "char";
        else if(t == 3)
        return "float";
        else if(t == 4)
        return "int*";
        else if(t == 5)
        return "float*";
      
      return "error";
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
        if(p[i] == '\0')
        break;
        if(p[i] == ' '){
            count++;
            continue;
        }


        if(count == paramIndex){
            int len = strlen(res);  // Find the current length of the string.
            res[len] = p[i];          // Add the new character at the end of the string.
            res[len + 1] = '\0';
        }
        else if(count>paramIndex){
            break;
        }

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
void printSymbolTable();
void printConstantTable();
struct stack
{
	char value[100];
	int labelvalue;
}s[100],label[100];


void push(char *x)
{
   
	strcpy(s[++top].value,x);
}


void codegen()
{
    
	printf("t%d = %s %s %s\n",count,s[top-2].value,s[top-1].value,s[top].value);
	top = top - 2;
    sprintf(temp, "t%d", count);
	strcpy(s[top].value,temp);
	count++;
}

void appendTop(char* s1)
{
	strcat(s[top].value,s1);
	
}

void codegencon()
{
   
	if(array_flag == 1){
		printf("t%d = 4 * %s\n",count ,current_whatever);
		count++;
		printf("t%d = &arr + t%d\n",count ,count-1);
		array_tac_flag = 1;
	}
	else
		printf("t%d = %s\n",count ,current_value);
	sprintf(temp, "t%d", count);
	push(temp);
	count++;
	array_flag = 0;
}

void codeassign()
{
   
	if(array_tac_flag == 1)
		printf("*%s = %s\n",s[top-2].value,s[top].value);
	else
		printf("%s = %s\n",s[top-2].value,s[top].value);
	array_tac_flag = 0;
	top = top - 2;
}

int isunary(char *s)
{
	if(strcmp(s, "--")==0 || strcmp(s, "++")==0)
	{
		return 1;
	}
	return 0;
}

void genunary()
{
	char temp1[100], temp2[100], temp3[100];
	strcpy(temp1, s[top].value);
	strcpy(temp2, s[top-1].value);

    

	if(isunary(temp1))
	{
		strcpy(temp3, temp1);
		strcpy(temp1, temp2);
		strcpy(temp2, temp3);
	}

	if(strcmp(temp2,"--")==0)
	{
		printf("t%d = %s - 1\n", count, temp1);
		printf("%s = t%d\n", temp1, count);
	}

	if(strcmp(temp2,"++")==0)
	{
		printf("t%d = %s + 1\n", count, temp1);
		printf("%s = t%d\n", temp1, count);
	}
	count++;
	top = top -2;
}


void label1()
{
	printf("IF not %s goto L%d\n",s[top].value,lno);
	label[++ltop].labelvalue = lno++;
}

void label2()
{
	printf("goto L%d\n",lno);
	printf("L%d:\n",label[ltop].labelvalue);
	ltop--;
	label[++ltop].labelvalue=lno++;
}

void label3()
{
	printf("L%d:\n",label[ltop].labelvalue);
	ltop--;
}

void label4()
{
	printf("L%d:\n",lno);
	label[++ltop].labelvalue = lno++;
}


void label5()
{
	printf("goto L%d:\n",label[ltop-1].labelvalue);
	printf("L%d:\n",label[ltop].labelvalue);
	ltop = ltop - 2;
}



void start_function()
{
	printf("func begin %s\n",current_function);
}

void end_function()
{
	printf("func end\n\n");
}
void top_(){
    int i=top;
    while(i>=0){ printf("  %s  ",s[i].value);i--;}
    printf("\n\n");
}

void arggen()
{
   
  
    
	printf("param %s\n", s[top].value);
    top--;
	
	
}

void callgen()
{
	printf("refparam result\n");
	push("result");
    if(strcmp(currfunccall,"printf"))
	printf("call %s, %d\n",currfunccall,getSTparamscount(currfunccall));
    else printf("call %s, %d\n",currfunccall,printCount);
}

int main() {
    yyin = fopen("test26.c", "r");
    if(yyin==NULL) printf("Unable to open file");
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

int newGetType(char* s){
    char* res = "";
    int t = -1;

        for(int i = 0 ; i < 1001 ; i++ )
      {
        if(strcmp(ST[i].symbol_name,s)==0)
        {
          res = ST[i].symbol_type;
          break;
        }
      }

        if(strcmp(res,"char*") == 0 ){
            t = 0;
        }
        else if (res[0] == 's') {
            t = 0;  // Indicate it's a string
        } 
        else if (strcmp(res,"int") == 0) {
            t = 1;  // Indicate it's a numeric type
            //current_exp_type = current_exp_type<1? 1: current_exp_type ;
        }
        else if (strcmp(res,"char") == 0) {
            t = 2;  // Indicate it's a numeric type
            //current_exp_type = current_exp_type<2? 2: current_exp_type ;
        }
        else if (strcmp(res,"float") == 0) {
            t = 3;  // Indicate it's a numeric type
            //current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }
        else if (strcmp(res,"int*") == 0) {
            t = 4;  // Indicate it's a numeric type
            //current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }
        else if (strcmp(res,"float*") == 0) {
            t = 5;  // Indicate it's a numeric type
            //current_exp_type = current_exp_type<3? 3: current_exp_type ;
        }

         else {
            t = checkConstantTable(s);
        }

        return t;
}

int checkConstantTable(char* s){
    for(int i = 0 ; i < 1001 ; i++ )
      {
        if(strcmp(CT[i].constant_name,s)==0)
        {
            
          if(strcmp(CT[i].constant_type,"Floating Constant") == 0)
            return 3;
          if(strcmp(CT[i].constant_type,"Number Constant") == 0)
            return 1;
          if(strcmp(CT[i].constant_type,"Character Constant") == 0)
            return 2;
          if(strcmp(CT[i].constant_type,"String Constant") == 0)
            return 0;
        }
      }

      return -1;
}


int newCheckCompatibility(int a, int b){
    if(a == 1 || a== 2){
        if(b == 1||b == 2)
        return 1;
    }
    if(a == 3)
    if(b == 1 || b == 2 || b == 3){
        return 1;
    }

    return (a == b || b == 6);
}

int giveIndex(char* str){
    for(int i=0; i<1000; i++)
    {
      if(strcmp(ST[i].symbol_name, str) == 0 && strcmp(ST[i].class, "Function") == 0 &&ST[i].define==1|| strcmp(ST[i].symbol_name,"printf")==0 )
      {
        return i;
      }
    }
    return -1;
}