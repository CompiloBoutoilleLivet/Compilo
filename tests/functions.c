
int toto(int a, int z);

int main(const int a)
{
	toto(a, a);
}

int toto(int a, int z)
{
	int x = a + 10;
	toto(x, x);
}
