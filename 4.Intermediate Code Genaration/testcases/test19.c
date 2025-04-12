//WITH ERROR - This test case includes void return for int function
#include<stdio.h>
int func()
{
	printf("hello\n");
	return;
}
void main()
{
	func();
}

