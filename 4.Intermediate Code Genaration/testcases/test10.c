//ERROR FREE: This testcase includes multiple functions
#include<stdio.h>
int add(int a, int b, int c)
{
	int res;
	res = a + b + c; 
	return res;
}
int multiply(int a, int b, int c)
{
	int res;
	res = a * b * c;
	return res;
}
void main()
{
	int a = 2, b = 3, c = 4;
	int sum = add(a,b,c);
	int product = multiply(a,b,c);
}
