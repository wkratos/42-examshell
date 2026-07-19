#include <stdio.h>
#include <stdlib.h>

char *ft_strdup(char *src);

int main(int argc, char **argv)
{
    char *copy;

    if (argc != 2)
        return (1);
    copy = ft_strdup(argv[1]);
    if (copy == NULL)
        return (2);
    printf("content:%s\n", copy);
    printf("storage:%s\n", copy == argv[1] ? "borrowed" : "allocated");
    if (copy != argv[1])
        free(copy);
    return (0);
}
