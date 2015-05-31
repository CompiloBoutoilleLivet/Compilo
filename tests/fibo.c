
int fibo(int n);

int main()
{
	int x = 0;
	while(x < 30)
	{
		printf(fibo(x));
		x = x + 1;
	}
}

int fibo(int n)
{
	if(n <= 1)
	{
		return n;
	} else {
		return fibo(n-1) + fibo(n-2);
	}
}
