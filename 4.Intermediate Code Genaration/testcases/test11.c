//ERROR FREE: This testcase contains a program tp swap 2 numbers
#include<stdio.h>
void main()
{
	int a = 10, b = 20;
	printf("\na = %d, b = %d", a,b);
	int temp = a;
	a = b;
	b = temp;
	printf("\na = %d, b = %d", a,b);
}
