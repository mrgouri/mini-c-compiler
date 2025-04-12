//WITH ERROR - This test case includes duplicate function declaration
#include<stdio.h>
void func()
{
	printf("hello\n");
}
void func()
{
	printf("hello\n");
}
void main()
{
	printf("hello\n");
}
