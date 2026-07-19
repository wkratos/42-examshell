#include <stdio.h>

char    *ft_strcpy(char *s1, char *s2);

int main(int argc, char **argv)
{
	char destination[4096];
	char *returned;

	if (argc != 3)
		return (1);
	(void)argv[1];
	destination[0] = '\0';
	returned = ft_strcpy(destination, argv[2]);
	printf("content:%s\n", destination);
	printf("return:%s\n", returned == destination ? "destination" : "wrong-pointer");
	return (0);
}
