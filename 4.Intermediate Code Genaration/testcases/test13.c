//WITH ERROR - This test case includes duplicate declaration of identifier
#include<stdio.h>

void main()
{
	int a = 1;
	int a = 2;
	printf("%d", a);
	
}
