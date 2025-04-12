//WITH ERROR - This test case includes a function call to function declared after main
#include<stdio.h>
void main()
{
	func();
}
void func()
{
	printf("hello\n");
}
