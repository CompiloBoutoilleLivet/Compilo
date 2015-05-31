
int fibo(int n)
{
	if(n <= 1)
	{
		return n;
	} else {
		return fibo(n-1) + fibo(n-2);
	}
}

int main()
{
	int i = 0;
	printf(fibo(i));
}
