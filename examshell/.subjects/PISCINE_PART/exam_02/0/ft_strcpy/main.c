#include <stdio.h>

char    *ft_strcpy(char *s1, char *s2);

int main(int argc, char **argv)
{
	(void)argc;
	char destination[4096] = "";
	char *returned = ft_strcpy(destination, argv[2]);
	printf("content:%s\n", destination);
	printf("return:%s\n", returned == destination ? "destination" : "wrong-pointer");
	return (0);
}
