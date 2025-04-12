//ERROR FREE: This testcase includes a program to find factorial of a number
#include <stdio.h>
int main()
{
	int n = 7, i;
	int fact = 1;
	if (n < 0)
		printf("\nError!");
	else
	{
		for (i = 1; i <= n; i++)
		{
			fact = fact * i;
		}
		printf("Factorial of %d = %d", n, fact);
	}

	return 0;
}

