#include <stdio.h>
#include <stdlib.h>

void ft_swap(int *a, int *b);

int main(int argc, char **argv)
{
    int a;
    int b;

    if (argc != 3)
        return (1);
    a = atoi(argv[1]);
    b = atoi(argv[2]);
    ft_swap(&a, &b);
    printf("%d\n%d\n", a, b);
    return (0);
}
