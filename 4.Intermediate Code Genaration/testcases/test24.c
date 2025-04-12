//WITH ERROR - This test case includes case value in subscript not integer
#include<stdio.h>
void main()
{
	int ar[2] = {1, 2};
	float y = 1.0;
	ar[y] = 1;

}

