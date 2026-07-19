#include <stdio.h>
#include <stdlib.h>

int is_power_of_2(unsigned int n);

int main(int argc, char **argv)
{
    if (argc != 2)
        return (1);
    printf("%d", is_power_of_2((unsigned int)strtoul(argv[1], NULL, 10)));
    return (0);
}
