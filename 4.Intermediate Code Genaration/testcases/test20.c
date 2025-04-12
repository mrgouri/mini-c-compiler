//WITH ERROR - This test case includes int return for void function
#include<stdio.h>
void func()
{
	printf("hello\n");
	return 0;
}
void main()
{
	func();
}

