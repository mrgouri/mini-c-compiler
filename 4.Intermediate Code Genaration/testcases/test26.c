//WITH ERROR- This test case includes use of out of scope id
#include <stdio.h>
void main()
{
	int x = 1;
	if(1)
	{
		int y = 2;
	}
	y = 3;
}
