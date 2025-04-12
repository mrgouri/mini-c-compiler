%option yylineno
%{
  #include <stdio.h>
  #include <string.h>
  #include<stdlib.h>
  #include "y.tab.h"

  struct ConstantTable{
    char constant_name[100];
    char constant_type[100];
    int exist;
  }CT[1000];

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
  }ST[1000];

  int current_nested_val = 0;
  int params_count = 0;


  unsigned long hash(unsigned char *str)
  {
    unsigned long hash = 5381;
    int c;

    while (c = *str++)
      hash = ((hash << 5) + hash) + c;

    return hash;
  }

  int search_ConstantTable(char* str){
    unsigned long temp_val = hash(str);
    int val = temp_val%1000;

    if(CT[val].exist == 0){
      return 0;
    }

    else if(strcmp(CT[val].constant_name, str) == 0)
    {
      return 1;
    }
    else
    {
      for(int i = val+1 ; i!=val ; i = (i+1)%1000)
      {
        if(strcmp(CT[i].constant_name,str)==0)
        {
          return 1;
        }
      }
      return 0;
    }
  }


  int search_SymbolTable(char* str){
    unsigned long temp_val = hash(str);
    int val = temp_val%1000;

    if(ST[val].exist == 0){
      return 0;
    }

    else if(strcmp(ST[val].symbol_name, str) == 0)
    {
      return val;
    }
    else
    {
      for(int i = val+1 ; i!=val ; i = (i+1)%1000)
      {
        if(strcmp(ST[i].symbol_name,str)==0)
        {
          return i;
        }
      }
      return 0;
    }
  }


  void insert_ConstantTable(char* name, char* type){
    int index = 0;
     if(search_ConstantTable(name)){
      return;
    }
    else{
      unsigned long temp_val = hash(name);
      int val = temp_val%1000;
      if(CT[val].exist == 0){
        strcpy(CT[val].constant_name, name);
        strcpy(CT[val].constant_type, type);
        CT[val].exist = 1;
        return;
      }

      for(int i = val+1; i != val; i = (i+1)%1000){
        if(CT[i].exist == 0){
          index = i;
          break;
        }
      }
      strcpy(CT[index].constant_name, name);
      strcpy(CT[index].constant_type, type);
      CT[index].exist = 1;			
    }
  }

  void insert_SymbolTable(char* name, char* class){
    int index = 0;
    //printf("BBBB");
     if(search_SymbolTable(name)){
      //printf("AAAAAA");
      return;
    }
    else{
      unsigned long temp_val = hash(name);
      int val = temp_val%1000;
      if(ST[val].exist == 0){
        strcpy(ST[val].symbol_name, name);
        strcpy(ST[val].class, class);
          ST[val].nested_val = 100;
        //ST[val].params_count = -1;
                ST[val].line_number = yylineno;
        ST[val].exist = 1;
        return;
      }

      for(int i = val+1; i != val; i = (i+1)%1000){
        if(ST[i].exist == 0){
          index = i;
          break;
        }
      }

      strcpy(ST[index].symbol_name, name);
      strcpy(ST[val].class, class);
      ST[index].nested_val = 100;
      //ST[index].params_count = -1;
      ST[index].exist = 1;			
              if(strcmp("Function", class) == 0)ST[index].define = 1;
    }
  }

  void insert_SymbolTable_type(char *str1, char *str2)
  {
    for(int i = 0 ; i < 1000 ; i++)
    {
      if(strcmp(ST[i].symbol_name,str1)==0)
      {
        strcpy(ST[i].symbol_type,str2);
      }
    }
    }

  void insert_SymbolTable_value(char *str1, char *str2)
  {
    for(int i = 0 ; i < 1001 ; i++)
    {
      if(strcmp(ST[i].symbol_name,str1)==0 && ST[i].nested_val != current_nested_val)
      {
        strcpy(ST[i].value,str2);
      }
    }
  }

    void insert_SymbolTable_arraydim(char *str1, char *dim)
  {
    for(int i = 0 ; i < 1000 ; i++)
    {
      if(strcmp(ST[i].symbol_name,str1)==0)
      {
        strcpy(ST[i].array_dimensions,dim);
      }
    }
  }

    void insert_SymbolTable_funcparam(char *str1, char *param)
  {
    for(int i = 0 ; i < 1000 ; i++)
    {
      if(strcmp(ST[i].symbol_name,str1)==0)
      {
        strcat(ST[i].parameters," ");
                strcat(ST[i].parameters,param);
      }
    }
  }

  void insert_SymbolTable_line(char *str1, int line)
  {
    for(int i = 0 ; i < 1000 ; i++)
    {
      if(strcmp(ST[i].symbol_name,str1)==0)
      {
        ST[i].line_number = line;
      }
    }
  }

  void insert_SymbolTable_nest(char *s, int nest)
  {
    //printf("mlkjhad %d", nest);
    if(search_SymbolTable(s) && ST[search_SymbolTable(s)].nested_val != 100)
    {
      //printf("mlkjhad %d\n", nest);
             int pos = 0;
             int value = hash(s);
       value = value%1001;
      for (int i = value + 1 ; i!=value ; i = (i+1)%1001)
      {
        if(ST[i].exist == 0)
        {
          pos = i;
          break;
        }
      }

      strcpy(ST[pos].symbol_name,s);
      strcpy(ST[pos].class,"Identifier");
      ST[pos].nested_val = nest;
      //printf("afafa %s\n", ST[pos].symbol_name);
      //ST[pos].params_count = -1;
      ST[pos].line_number = yylineno;
      ST[pos].exist = 1; 
    }
    else
    {
      for(int i = 0 ; i < 1001 ; i++)
      {
        if(strcmp(ST[i].symbol_name,s)==0 )
        {
          ST[i].nested_val = nest;
        }
      }
    }
  }

  int check_scope(char *s)
  {
    int flag = 0;
    for(int i = 0 ; i < 1000 ; i++)
    {
      if(strcmp(ST[i].symbol_name,s)==0)
      {
        if(ST[i].nested_val > current_nested_val)
        {
          flag = 1;
        }
        else
        {
          flag = 0;
          break;
        }
      }
    }
    if(!flag)
    {
      return 1;
    }
    else
    {
      return 0;
    }
  }

  void remove_scope (int nesting)
  {
    for(int i = 0 ; i < 1000 ; i++)
    {
      if(ST[i].nested_val == nesting)
      {
        ST[i].nested_val = 100;
      }
    }
  }

  void insert_SymbolTable_function(char *s)
  {
            printf("definig....");
    for(int i = 0 ; i < 1001 ; i++)
    {
      if(strcmp(ST[i].symbol_name,s)==0 )
      {
        strcpy(ST[i].class,"Function");
            ST[i].define=0;
        return;
      }
    }

  }

            void updateDefine(char *s)
            {
                      printf("updating....");
              for(int i = 0 ; i < 1001 ; i++)
              {
                if(strcmp(ST[i].symbol_name,s)==0 )
                {
                  
                      ST[i].define=1;
                  return;
                }
              }

            }
            
  void insert_SymbolTable_function2(char *s)
            {
            printf("declaring....);");
              for(int i = 0 ; i < 1001 ; i++)
              {
                if(strcmp(ST[i].symbol_name,s)==0 )
                {
                  strcpy(ST[i].class,"Function");
                      ST[i].define=1;
                  return;
                }
              }

            }

  int check_function(char *s)
  {
    for(int i = 0 ; i < 1000 ; i++)
    {
      if(strcmp(ST[i].symbol_name,s)==0)
      {
        if(strcmp(ST[i].class,"Function")==0)
          return 1;
      }
    }
    return 0;
  }

  int check_array(char *s)
  {
    for(int i = 0 ; i < 1000 ; i++)
    {
      if(strcmp(ST[i].symbol_name,s)==0)
      {
        if(strcmp(ST[i].class,"Array Identifier")==0)
        {
          return 0;
        }
      }
    }
    return 1;
  }

  int duplicate(char *s)
  {
    for(int i = 0 ; i < 1000 ; i++)
    {
      if(strcmp(ST[i].symbol_name,s)==0)
      {				
        if(ST[i].nested_val == current_nested_val)
        {
              return 1;
        }
      }
    }

    return 0;
  }

  int check_duplicate(char* str)
  {
    for(int i=0; i<1000; i++)
    {
      if(strcmp(ST[i].symbol_name, str) == 0 && strcmp(ST[i].class, "Function") == 0)
      {
        if(ST[i].define==0){
        printf("ERROR: Cannot Redeclare same function!\n");
        printf("\nUNSUCCESSFUL: INVALID PARSE\n");
        exit(0);}
            else ST[i].define=1;
      }
    }
  }

  int check_declaration(char* str, char *check_type)
  {
    for(int i=0; i<1000; i++)
    {
      if(strcmp(ST[i].symbol_name, str) == 0 && strcmp(ST[i].class, "Function") == 0 &&ST[i].define==1|| strcmp(ST[i].symbol_name,"printf")==0 )
      {
        return 1;
      }
    }
    return 0;
  }

  int check_params(char* type_specifier)
  {
    if(!strcmp(type_specifier, "void"))
    {
      printf("ERROR: Here, Parameter cannot be of void type\n");
      printf("\nUNSUCCESSFUL: INVALID PARSE\n");
      exit(0);
    }
    return 0;
  }

  void insert_SymbolTable_paramscount(char *s, int count)
  {
    for(int i = 0 ; i < 1000 ; i++)
    {
      if(strcmp(ST[i].symbol_name,s)==0 )
      {
        ST[i].params_count = count;
      }
    }
  }

  int getSTparamscount(char *s)
  {
    for(int i = 0 ; i < 1000 ; i++)
    {
      if(strcmp(ST[i].symbol_name,s)==0 )
      {
        return ST[i].params_count;
      }
    }
    return -2;
  }
  int getSTdimensioncount(char *s) {
    for (int i = 0; i < 1000; i++) {
        if (strcmp(ST[i].symbol_name, s) == 0) {
            return atoi(ST[i].array_dimensions);
        }
    }
    return -2;
   }
  char gettype(char *s, int flag)
  {
      for(int i = 0 ; i < 1001 ; i++ )
      {
        if(strcmp(ST[i].symbol_name,s)==0)
        {
          return ST[i].symbol_type[0];
        }
      }

  }

  void printConstantTable(){
    printf("%20s | %20s\n", "CONSTANT","TYPE");
    for(int i = 0; i < 1000; ++i){
      if(CT[i].exist == 0)
        continue;

      printf("%20s | %20s\n", CT[i].constant_name, CT[i].constant_type);
    }
  }

  void printSymbolTable(){
        printf("%10s | %18s | %10s | %10s | %10s | %10s | %10s | %10s | %10s\n","SYMBOL", "CLASS", "TYPE","VALUE","DIMENSIONS","PARAMETERS","PARAMETER COUNT", "NESTING", "LINE NO");
    for(int i = 0; i < 1000; ++i){
      if(ST[i].exist == 0)
        continue;
      printf("%10s | %18s | %10s | %10s | %10s | %10s | %15d | %10d | %d\n", ST[i].symbol_name, ST[i].class, ST[i].symbol_type, ST[i].value,ST[i].array_dimensions,ST[i].parameters, ST[i].params_count, ST[i].nested_val,ST[i].line_number);
    }
  }
  char current_identifier[20];
  char current_type[20];
  char current_value[20];
    char current_function[20];
  char previous_operator[20];
  int flag;

%}

num              	[0-9]
alpha              	[a-zA-Z]
alphanum            {alpha}|{num}
escape_sequences    0|a|b|f|n|r|t|v|"\\"|"\""|"\'"
ws  				[ \t\r\f\v]+
%x MLCOMMENT
DE "define"
IN "include"

%%

  int nested_count = 0;
  int check_nested = 0;

\n 	{yylineno++;}
"#include"[ ]*"<"{alpha}({alphanum})*".h>"                                  	{ }
"#define"[ ]+(_|{alpha})({alphanum})*[ ]*(.)+                                   { } 
"//".*  																		{ }

"/*"             							 { BEGIN MLCOMMENT; }
<MLCOMMENT>"/*"							 	 { ++nested_count; 
                        check_nested = 1;
                       }	
<MLCOMMENT>"*"+"/"        					 { if (nested_count) --nested_count;
                         else{ if(check_nested){
                            check_nested = 0;
                            BEGIN INITIAL;
                            }
                           else{
                            BEGIN INITIAL;
                          }
                          } 
                       }
<MLCOMMENT>"*"+           					 ; 
<MLCOMMENT>[^/*\n]+						 	 ;
<MLCOMMENT>[/]    							 ;
<MLCOMMENT>\n     							 ;
<MLCOMMENT><<EOF>>							 { printf("Line No. %d ERROR: MULTI LINE COMMENT NOT CLOSED\n", yylineno); return 0;}

"["                                          {return *yytext;}
"]"                                          {return *yytext;}
"("                                          {return *yytext;}
")"                                          {return *yytext;}
"{"                                          {return *yytext;}
"}"                                          {return *yytext;}
","                                          {return *yytext;}
";"                                          {return *yytext;}



"char"			{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword"); return CHAR;}
"double"		{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword"); return DOUBLE;}
"else"			{ insert_SymbolTable_line(yytext, yylineno); insert_SymbolTable(yytext, "Keyword"); return ELSE;}
"float"			{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");return FLOAT;}
"while"			{ insert_SymbolTable(yytext, "Keyword"); return WHILE;}
"NULL"			{ return NULL;}
"do"			{ insert_SymbolTable(yytext, "Keyword"); return DO;}
"for"			{ insert_SymbolTable(yytext, "Keyword"); return FOR;}
"if"			{ insert_SymbolTable(yytext, "Keyword"); return IF;}
"int"			{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");return INT;}
"long"			{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");  return LONG;}
"return"		{ insert_SymbolTable(yytext, "Keyword");  return RETURN;}
"short"			{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");  return SHORT;}
"signed"		{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");  return SIGNED;}
"sizeof" 		{ insert_SymbolTable(yytext, "Keyword");  return SIZEOF;}
"struct" 		{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");  return STRUCT;}
"unsigned"		{ insert_SymbolTable(yytext, "Keyword");  return UNSIGNED;}
"void"			{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");  return VOID;}
"break"			{ insert_SymbolTable(yytext, "Keyword");  return BREAK;}
"continue"		{ insert_SymbolTable(yytext, "Keyword");  return CONTINUE;}
"goto"			{ insert_SymbolTable(yytext, "Keyword");  return GOTO;}
"switch"		{ insert_SymbolTable(yytext, "Keyword");  return SWITCH;}
"case"			{ insert_SymbolTable(yytext, "Keyword");  return CASE;}
"default"		{ insert_SymbolTable(yytext, "Keyword");  return DEFAULT;}

("\"")[^\n\"]*("\"")                         {strcpy(current_value,yytext); insert_ConstantTable(yytext,"String Constant"); return string_constant;}        
("\"")[^\n\"]*                               { printf("Line No. %d ERROR: UNCLOSED STRING - %s\n", yylineno, yytext); return 0;}
("\'")(("\\"({escape_sequences}))|.)("\'")   {strcpy(current_value,yytext); insert_ConstantTable(yytext,"Character Constant"); return character_constant;}
("\'")(((("\\")[^0abfnrtv\\\"\'][^\n\']*))|[^\n\''][^\n\'']+)("\'") {printf("Line No. %d ERROR: NOT A CHARACTER - %s\n", yylineno, yytext); return 0; }
{num}+(\.{num}+)?e{num}+   		        {strcpy(current_value,yytext); insert_ConstantTable(yytext, "Floating Constant"); return float_constant;} 
{num}+\.{num}+                		    {strcpy(current_value,yytext); insert_ConstantTable(yytext, "Floating Constant"); return float_constant;}                                             
{num}+                           	   	{strcpy(current_value,yytext); insert_ConstantTable(yytext, "Number Constant"); yylval = atoi(yytext); return integer_constant;}    
(_|{alpha})({alpha}|{num}|_)*  		{strcpy(current_identifier,yytext);insert_SymbolTable(yytext,"Identifier");  return identifier;}
(_|{alpha})({alpha}|{alpha}|_)*/\[  	{strcpy(current_identifier,yytext);insert_SymbolTable(yytext,"Array Identifier");  return array_identifier;}
{ws}										 ;

"+"											 {return *yytext;}
"-"											 {return *yytext;}
"*"											 {return *yytext;}
"/"											 {return *yytext;}
"="											 {return *yytext;}
"%"											 {return *yytext;}
"&"											 {return *yytext; }
"^"											 {return *yytext; }
"++"										 {return INCREMENT;}
"--"										 {return DECREMENT;}
"!"											 {return NOT;}
"+="										 {return ADD_EQUAL;}
"-="										 {return SUBTRACT_EQUAL;}
"*="										 {return MULTIPLY_EQUAL;}
"/="										 {return DIVIDE_EQUAL;}
"%="										 {return MOD_EQUAL;}
"&&"										 {return AND_AND;}



"||"										 {return OR_OR;}
">"											 {return GREAT;}
"<"											 {return LESS;}
">="										 {return GREAT_EQUAL;}
"<="										 {return LESS_EQUAL;}
"=="										 {return EQUAL;}
"!="										 {return NOT_EQUAL;}
.											 { flag = 1;
                         if(yytext[0] == '#')
                          printf("Line No. %d PREPROCESSOR ERROR - %s\n", yylineno, yytext);
                         else
                          printf("Line No. %d ERROR: ILLEGAL CHARACTER - %s\n", yylineno, yytext);
                        return 0;}

%%