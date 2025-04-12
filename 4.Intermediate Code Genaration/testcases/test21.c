//WITH ERROR - This test case includes function call with incorrect number of parameters during call
#include<stdio.h>
int func(int a, int b)
{
	return a+b;
}
void main()
{
	int a = 1;
	int x;
	x = func(a);
}

