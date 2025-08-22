#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>

#ifndef BUFFER_SIZE
#define BUFFER_SIZE 42
#endif

char *ft_strjoin(char *s1, char s2)
{
	int i = 0;
	char *r;

	if (!s1)
	{
		r = malloc(2);
		if(!r)
			return (NULL);
		r[0] = s2;
		r[1] = '\0';
		return (r);
	}
	while(s1[i])
		i++;
	r = malloc(i + 2);
	if(!r)
		return (NULL);
	i = 0;
	while (s1[i])
	{
		r[i] = s1[i];
		i++;
	}
	r[i] = s2;
	r[i + 1] = '\0';
	free(s1);
	return (r);
}

char *get_next_line(int fd)
{
	static char buffer[BUFFER_SIZE + 1];
	static int pos = 0;
	static int rd = 0;
	char c;
	char *line = NULL;

	if (fd < 0 || BUFFER_SIZE <= 0)
		return (NULL);
	while (1)
	{
		if (pos >= rd)
		{
			pos = 0;
			rd = read(fd, buffer, BUFFER_SIZE);
			if (rd <= 0)
				break;
		}
		c = buffer[pos++];
		line = ft_strjoin(line, c);
		if (!line)
			return (NULL);
		if (c == '\n')
			break;
	}
	return (line && *line) ? line : NULL;
}
