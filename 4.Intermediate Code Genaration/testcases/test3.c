//ERROR FREE - This test case includes arrays and conditional statements
#include<stdio.h>

int main()
{
	int a[2];
	a[0] = 5;
	a[1] = 2;
	char b = 'a';
	
	if(b == 'a'){
		if(a[0] == 5)
			printf("Hello 1");
		else
			printf("Hello 2");
	}
	else
		printf("Not Hello");
}
	
