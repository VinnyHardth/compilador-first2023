#include <stdio.h>

float media(float a,float b,float c)
{
	return (a+b+c)/3.0;
}



void main()
{
	float n1 = 10.0;
	float n2 = 8.5;
	float n3 = 5.4;
	int m = media(n1,n2, n3);

	if (m > 6)
	{
		output("Aprovado\n");
	}
	else
	{
		output("Reprovado\n");
	}


	//float m = media(n1,n2);
}




