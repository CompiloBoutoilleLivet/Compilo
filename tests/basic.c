int main()
{
	int a1 = 0;
	int a2 = 1;
	int a3 = 2;
	int i = 0;
	int b = 1337;

	while(i <= 20)
	{
		int b = i + 1;
		printf(b);

		if(i >= 20)
		{
			int b = 0;
			printf(b);
			printf(a3);
			printf(i);
		} else if(i >= 10)
		{
			printf(a2);
			printf(i);
		} else {
			printf(a1);
			printf(i);
		}

		i = i + 1;
	}

}
