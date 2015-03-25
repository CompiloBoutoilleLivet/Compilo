int main()
{
	int a1 = 0;
	int a2 = 1;
	int a3 = 2;
	int i = 0;
	int b = 1337;

	while(i < 20)
	{
		if(i > 15)
		{
			printf(a1);
			printf(i);
		}
		else if(i > 10)
		{
			printf(a2);
			printf(i);
		} else {
			printf(a3);
			printf(i);
		}

		i = i + 1;
	}

}
