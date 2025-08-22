#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <netdb.h>
#include <string.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/select.h>

typedef struct s_clients {
    int id;
    char msg[1000000];
} t_clients;

t_clients client[1024];

fd_set write_set, read_set, current;

int max_fd = 0, current_id = 0;

char send_buffer[1000030], recv_buffer[1000000];

void ft_err(char *srt) {
    if (srt)
        write(2, srt, strlen(srt));
    else
        write(2, "Fatal error\n", 12);
    exit(1);
}

void ft_broadcast(int exc) {
    for (int fd = 0; fd <=max_fd; fd++) {
        if (FD_ISSET(fd, &write_set) && exc != fd)
            if (send(fd, send_buffer, strlen(send_buffer), 0) == -1)
                ft_err(NULL);
    }
}

int main(int ac, char **av) {
    if (ac != 2)
        ft_err("Wrong number of arguments\n");

    struct sockaddr_in srv;
    socklen_t len = sizeof(srv);
    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd == -1)
        ft_err(NULL);
    max_fd = sockfd;

    FD_ZERO(&current);
    FD_SET(sockfd, &current);
    bzero(client, sizeof(client));
    bzero(&srv, sizeof(srv));

    srv.sin_family = AF_INET;
    srv.sin_addr.s_addr = htonl(2130706433);
    srv.sin_port = htons(atoi(av[1]));

    if (bind(sockfd, (const struct sockaddr *)&srv, sizeof(srv)) == -1 || listen(sockfd, 100) == -1)
        ft_err(NULL);

    while (1) {
        write_set =read_set = current;
        if (select(max_fd + 1, &read_set, &write_set, 0, 0) == -1)
            continue ;

        for (int fd = 0; fd <= max_fd; fd++) {
            if (FD_ISSET(fd, &read_set)) {
                if (sockfd == fd) {
                    int con = accept(sockfd, (struct sockaddr *)&srv, &len);
                    if (con == -1)
                        continue ;
                    if (con > max_fd)
                        max_fd = con;
                    client[con].id = current_id;
                    current_id++;
                    FD_SET(con, &current);
                    sprintf(send_buffer, "server: client %d just arrived\n", client[con].id);
                    ft_broadcast(con);
                } else {
                    int ret = recv(fd, recv_buffer, sizeof(recv_buffer), 0);
                    if (ret <= 0) {
                        sprintf(send_buffer, "server: client %d just left\n", client[fd].id);
                        ft_broadcast(fd);
                        FD_CLR(fd, &current);
                        close(fd);
                        bzero(client[fd].msg, strlen(client[fd].msg));
                    } else {
                        for (int i = 0, j = strlen(client[fd].msg); i < ret; i++, j++) {
                            client[fd].msg[j] = recv_buffer[i];
                            if (client[fd].msg[j] == '\n') {
                                client[fd].msg[j] = '\0';
                                sprintf(send_buffer, "client %d: %s\n", client[fd].id, client[fd].msg);
                                ft_broadcast(fd);
                                bzero(client[fd].msg, strlen(client[fd].msg));
                                j = -1;                               
                            }
                        }
                    }
                }
                break ;
            }
        }
    }
}